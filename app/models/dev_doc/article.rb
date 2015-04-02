require 'redcarpet'

module DevDoc
  class Article
    class PrismRenderer < Redcarpet::Render::HTML
      def block_code(code, lang)
        lang = lang && lang.split.first || "markup"
        lang = "markup" if lang == "html" # Prism refers to HTML as markup.
        html_escaped_code = ERB::Util.h(code)

        if lang.start_with?("live-html")
          iframe_attributes = lang.split(",").last if lang.include?(",")
          [
            %Q[<pre><code class="language-markup">#{html_escaped_code}</code></pre>],
            <<-EOF
              <div class="iframe-wrapper">
                <div class="iframe-loading"><i class="fa fa-refresh fa-spin fa-3x"></i></div>
                <iframe #{iframe_attributes} src="/dev/html_snippet?source=#{CGI.escape(code)}"></iframe>
              </div>
            EOF
          ].join
        else
          %Q[<pre><code class="language-#{lang}">#{html_escaped_code}</code></pre>]
        end
      end

      def block_quote(quote)
        type = quote.match(/<p>(\S+):/) {|m| m[1] }.to_s.downcase
        quote.sub!(/<p>(\S+):/, '<p>')
        %Q[<blockquote class="#{type}">#{quote}</blockquote>]
      end
    end

    RENDERER = PrismRenderer.new(with_toc_data: true)
    MARKDOWN = Redcarpet::Markdown.new(RENDERER, fenced_code_blocks: true, tables: true, autolink: true, strikethrough: true)
    YAML_DELIMITER = "==="

    attr_accessor :path

    def initialize(path)
      self.path = Pathname(path)
    end

    def body
      @body ||= Rails.cache.fetch(cache_key("body")) do
        Rails.logger.info("Render body for #{path}")
        MARKDOWN.render(body_string)
      end
    end

    def toc
      @toc ||= Rails.cache.fetch(cache_key("toc")) do
        TableOfContents.generate(body)
      end
    end

    def title
      metadata["title"] || retrieve_title
    end

    def retrieve_title
      Rails.cache.fetch(cache_key("body_h1")) do
        doc = Nokogiri::HTML(body)
        doc.css("h1").first.try(:text) || "Untitled"
      end
    end

    def rank
      metadata.fetch("rank", 0)
    end

    def metadata
      @metadata ||= Rails.cache.fetch(cache_key("metadata")) do
        Rails.logger.info("Loading YAML string for #{path}")
        YAML.load(yaml_string) || {}
      end
    end

    def body_string
      return @body_string if @body_string
      set_yaml_string_and_body_string
      @body_string
    end

    def yaml_string
      return @yaml_string if @yaml_string
      set_yaml_string_and_body_string
      @yaml_string
    end

    def set_yaml_string_and_body_string
      @yaml_string, @body_string = split_into_yaml_and_body
    end

    def split_into_yaml_and_body
      return ["", ""] unless exist?

      yaml_pieces, body_pieces = [], []
      yaml_section = false

      File.read(path).split("\n").each_with_index do |line, line_no|
        if (line_no.zero? && line == YAML_DELIMITER) || (yaml_section && line == YAML_DELIMITER)
          yaml_section = !yaml_section
        elsif yaml_section
          yaml_pieces << line
        else
          body_pieces << line
        end
      end

      [yaml_pieces.join("\n"), body_pieces.join("\n")]
    end

    def exist?
      File.exist?(path)
    end

    def cache_key(name)
      @base_cache_key ||= ["dev-decs-article", path, last_modified.to_i].join("/")
      "#{@base_cache_key}/#{name}"
    end

    def etag
      @etag ||= Digest::MD5.hexdigest(cache_key("etag"))
    end

    def last_modified
      @last_modified ||= File.mtime(path)
    end

    def nil?
      !exist?
    end
  end
end

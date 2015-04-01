module DevDoc
  class TableOfContents
    def self.generate(body)
      new(body).generate
    end

    attr_accessor :doc

    def initialize(body)
      self.doc = Nokogiri::HTML(body)
    end

    def generate
      allowed_tags = ["h2", "h3"]
      headings = doc.css("[id]").select {|el| allowed_tags.include?(el.name) }

      headings.each_with_object([]) do |heading, toc|
        id_attribute = heading.attributes.values.find {|attribute| attribute.name == "id" }

        next unless id_attribute

        toc_entry = {text: heading.text, id: id_attribute.value}

        if heading.name == "h2"
          toc << toc_entry
        elsif heading.name == "h3"
          toc.last[:children] ||= []
          toc.last[:children] << toc_entry
        end
      end
    end

  end
end
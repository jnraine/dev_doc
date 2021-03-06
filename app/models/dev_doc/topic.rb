module DevDoc
  class Topic
    def self.all
      Dir.entries(DevDoc.root).map do |basename|
        path = DevDoc.root.join(basename)
        next if basename.start_with?(".")

        if File.file?(path)
          ArticleTopic.new(path)
        else
          Topic.new(path)
        end
      end.compact
    end

    attr_accessor :index, :path, :children

    def initialize(path)
      self.path = path
      self.index = Article.new(path.join("index.md"))
      self.children = retrieve_children
    end

    def retrieve_children
      child_paths = Dir.entries(path).map {|entry| path.join(entry) }.select do |child_path|
        File.file?(child_path) && !child_path.basename.to_s.start_with?(".") && child_path.extname == ".md" && child_path.basename.to_s != "index.md"
      end
      child_paths.map {|child_path| Article.new(child_path) }.sort_by {|article| [article.rank*-1, article.title] }
    end

    def name
      @name ||= index.exist? ? index.title : File.basename(path).titleize
    end

    # For topics with a single article.
    class ArticleTopic
      attr_accessor :index, :path, :children, :name

      def initialize(path)
        self.path = path
        self.index = Article.new(path)
        self.children = []
        self.name = index.title
      end
    end
  end
end

module DevDoc
  class RootController < ApplicationController
    before_action :check_article

    def index
      @topics = Topic.all

      respond_to do |format|
        format.html { render text: article.body, layout: "dev_doc/application" }
      end
    end

    private

    def check_article
      return if article.exist?
      render text: "<h1>Not Found: #{article.path}</h1>", format: :html, layout: false, status: 404
    end

    def check_freshness
      return false unless stale?(etag: article.etag, last_modified: article.last_modified)
    end

    def article
      @article = Article.new(article_path)
    end

    def article_path
      root = DevDoc.root
      sub_path = params[:article_path].to_s

      if File.directory?(root.join(sub_path)) && File.exist?(root.join(sub_path, "index.md"))
        root.join(sub_path, "index.md")
      else
        root.join("#{sub_path}.md")
      end
    end
  end
end

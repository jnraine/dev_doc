module DevDoc
  module ApplicationHelper
    def article_path(article)
      file_path = article.path.to_s.sub(/index.md$/, '')
      article_path = file_path.sub("#{DevDoc.root}/", "").sub(/\..+$/, "")
      root_path(article_path: article_path)
    end
  end
end

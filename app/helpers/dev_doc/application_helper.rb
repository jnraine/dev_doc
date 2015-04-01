module DevDoc
  module ApplicationHelper
    def article_path(article)
      article_path = article.path.to_s.sub("#{DevDoc.root}/", "").sub(/\..+$/, "")
      root_path(article_path: article_path)
    end
  end
end

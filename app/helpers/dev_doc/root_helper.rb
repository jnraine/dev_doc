module DevDoc
  module RootHelper
    def article_path(article)
      file_path = article.path.to_s.sub(/index.md$/, '')
      article_path = file_path.sub("#{DevDoc.root}/", "").sub(/\..+$/, "")
      Pathname(root_path).join(article_path).to_s
    end
  end
end

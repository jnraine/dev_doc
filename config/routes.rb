DevDoc::Engine.routes.draw do
  get '(:article_path)' => 'root#index', constraints: { article_path: /.+/ }, as: :root
end

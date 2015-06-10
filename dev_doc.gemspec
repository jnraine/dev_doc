$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dev_doc/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dev_doc"
  s.version     = DevDoc::VERSION
  s.authors     = ["Jordan Raine"]
  s.email       = ["jordan.raine@clio.com"]
  s.homepage    = "http://google.com"
  s.summary     = "Documentation for your application."
  s.description = "Documentation for your application."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">=4.0"
  s.add_dependency "turbolinks", "~> 2.5.3"
  s.add_dependency "nokogiri", "~> 1.5"
  s.add_dependency "redcarpet", "~> 3.2.2"

  s.add_development_dependency "rspec-rails", "~> 2.14.1"
end

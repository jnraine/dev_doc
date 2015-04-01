require "turbolinks"
require "dev_doc/engine"

module DevDoc
  def self.root
    @root ||= Rails.root.join("dev-docs")
  end
end

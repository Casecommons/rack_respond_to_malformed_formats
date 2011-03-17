require "rubygems"
require "rspec"
require "rack"
require "rack/mock"

require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib/respond_to_malformed_formats"))

RSpec.configure do |config|
  config.mock_with :rspec
end

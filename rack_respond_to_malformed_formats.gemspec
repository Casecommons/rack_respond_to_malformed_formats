# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require File.join(File.dirname(__FILE__), "lib/rack/respond_to_malformed_formats")

Gem::Specification.new do |s|
  s.name        = "rack_respond_to_malformed_formats"
  s.version     = Rack::RespondToMalformedFormats::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Case Commons, LLC"]
  s.email       = ["casecommons-dev@googlegroups.com"]
  s.homepage    = "https://github.com/Casecommons/rack_respond_to_malformed_formats"
  s.license     = "MIT"
  s.add_dependency('activesupport', '>= 3.0.0')
  s.summary     = %q{Intercept malformed XML and JSON requests and return XML and JSON 400 responses not HTML 500}
  s.description = %q{Rails currently returns HTML 500 responses when sent unparsable XML and JSON and gives no way to rescue and handle it}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

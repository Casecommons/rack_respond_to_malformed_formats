# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rack_respond_to_malformed_formats"
  s.version     = "0.0.2"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Case Commons, LLC"]
  s.email       = ["casecommons-dev@googlegroups.com"]
  s.homepage    = "https://github.com/Casecommons/rack_respond_to_malformed_formats"
  s.license     = "MIT"
  s.summary     = %q{Intercept malformed XML and JSON requests and return XML and JSON 400 responses not HTML 500}
  s.description = %q{Rails currently returns HTML 500 responses when sent unparsable XML and JSON and gives no way to rescue and handle it}
  s.add_dependency('nokogiri', '>= 1.4.4')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

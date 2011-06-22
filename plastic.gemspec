# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "plastic"
  s.version     = "0.2.4"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Randy Reddig", "Cameron Walters", "Chris Kampmeier", "Erica Kwan", "Matthew O'Connor", "Damon McCormick", "Brian Jenkins", "Abhay Kumar"]
  s.email       = ["github@squareup.com"]
  s.summary     = "Credit card library for Ruby."
  s.description = "Handle credit, debit, bank and other cards."
  s.homepage    = "http://github.com/square/plastic"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "json"
  s.add_development_dependency "rspec"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "uuidtools"

  s.files        = Dir.glob("lib/**/*") + %w(README.rdoc)
  s.extra_rdoc_files = ["LICENSE.txt"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_path = 'lib'
end

require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

require File.join(File.dirname(__FILE__), 'lib', 'plastic', 'version')

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["--options", "spec/spec.opts"]
  t.pattern = 'spec/**/*_spec.rb'
  t.rcov = ENV["RCOV"]
  t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/}
  t.verbose = true
end

task :default => :spec

desc "Remove trailing whitespace"
task :whitespace do
  sh %{find . -name '*.rb' -exec sed -i '' 's/ *$//g' {} \\;}
end

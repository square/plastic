require 'rubygems'
require 'rake'
require 'spec/rake/spectask'

require File.join(File.dirname(__FILE__), 'lib', 'plastic', 'version')

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ["--options", "spec/spec.opts"]
  t.spec_files = FileList["spec/**/*_spec.rb"]
  t.rcov = ENV["RCOV"]
  t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/}
  t.verbose = true
end

task :default => :spec

desc "Remove trailing whitespace"
task :whitespace do
  sh %{find . -name '*.rb' -exec sed -i '' 's/ *$//g' {} \\;}
end

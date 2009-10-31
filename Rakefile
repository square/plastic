require 'rubygems'
require 'rake'
require 'spec/rake/spectask'
require 'spec/expectations'
require 'rake/rdoctask'

require File.join(File.dirname(__FILE__), 'lib', 'plastic', 'version')

PKG_BUILD     = ENV['PKG_BUILD'] ? '.' + ENV['PKG_BUILD'] : ''
PKG_NAME      = 'plastic'
PKG_VERSION   = Plastic::VERSION::STRING + PKG_BUILD
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

GEM_SPEC_NAME = File.join(File.dirname(__FILE__), "#{PKG_NAME}-#{PKG_VERSION}.gemspec")
GEM_NAME      = File.join(File.dirname(__FILE__), "#{PKG_NAME}-#{PKG_VERSION}.gem")

RELEASE_NAME  = "REL #{PKG_VERSION}"

PKG_FILES = FileList[
    "lib/**/*", "test/**/*", "doc/**/*", "[A-Z]*",
    "HISTORY.rdoc", "README.rdoc",
    "Rakefile"
]

desc "Run specs tests by default"
task :default => [:spec]

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ["--options", "spec/spec.opts"]
  t.spec_files = FileList["spec/**/*_spec.rb"]
  t.rcov = ENV["RCOV"]
  t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/}
  t.verbose = true
end


# Documentation

Rake::RDocTask.new { |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = "Plastic - Send short messages to your friends and frenemies."
  rdoc.options << '--line-numbers' << '--inline-source' << '-A cattr_accessor=object'
  rdoc.options << '--charset' << 'utf-8'
  rdoc.template = ENV['template'] ? "#{ENV['template']}.rb" : '../doc/template/horo'
  rdoc.rdoc_files.include('README.txt', 'HISTORY.rdoc', 'LICENSE.txt')
  rdoc.rdoc_files.include('lib/**/*.rb')
}


# Gems

spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.summary = "Credit card library for Ruby."
  s.description = "Handle credit, debit, bank and other cards."
  s.author = "Randy Reddig"
  s.email = "randy@squareup.com"
  s.homepage = "http://github.com/square/plastic"
  s.rubyforge_project = "plastic"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.extra_rdoc_files = ["HISTORY.rdoc", "LICENSE.txt", "README.rdoc"]
  s.files = [ "Rakefile", "LICENSE.txt", "README.rdoc", "HISTORY.rdoc" ]
  [ "lib", "test" ].each do |dir|
    s.files = s.files + Dir.glob( "#{dir}/**/*" )
  end

  s.has_rdoc = true
  s.rdoc_options.concat ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.5"

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      # s.add_runtime_dependency(%q<uuidtools>, [">= 2.0.0"])
    else
      # s.add_dependency(%q<uuidtools>, [">= 2.0.0"])
    end
  else
    # s.add_dependency(%q<uuidtools>, [">= 2.0.0"])
  end
end

namespace :gem do
  desc "Print gemspec"
  task :spec do
    open GEM_SPEC_NAME, "wb" do |file|
      file.write(spec.to_ruby)
    end
  end

  desc "Build gem with Gemcutter"
  task :build => :spec do
    system "gem build #{GEM_SPEC_NAME}"
  end

  desc "Push gem to Gemcutter"
  task :push => :build do
    system "gem push #{GEM_NAME}"
  end
end

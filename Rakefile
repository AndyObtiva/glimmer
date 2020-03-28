require 'rubygems'
require 'bundler'
require 'os'
require_relative 'lib/glimmer/launcher'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
begin
  jeweler_required = require 'jeweler'
rescue Exception
  jeweler_required = nil
end
unless jeweler_required.nil?
  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
    gem.name = "glimmer"
    gem.homepage = "http://github.com/AndyObtiva/glimmer"
    gem.license = "MIT"
    gem.summary = %Q{Desktop application development library}
    gem.description = %Q{JRuby Desktop UI DSL + Data-Binding library that enables easy and efficient authoring of user-interfaces using the robust platform-independent Eclipse SWT library}
    gem.email = "andy.am@gmail.com"
    gem.authors = ["AndyMaleh"]
    gem.executables = ['glimmer', 'girb']
    gem.files = Dir['bin/**/*', 'lib/**/*', 'vendor/**/*']
    # dependencies defined in Gemfile
  end
  Jeweler::RubygemsDotOrgTasks.new
end

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
  # spec.ruby_opts = ["-Xcli.debug=true --debug #{Glimmer::Launcher.jruby_swt_options}"]
  # NOTE: Disabled debug flags because they were giving noisy output on raise of an error
  spec.ruby_opts = [Glimmer::Launcher.jruby_swt_options]
end

task :default => :spec

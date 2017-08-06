require 'rubygems'
require 'bundler'
require 'os'
require_relative 'lib/glimmer_application'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
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
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
  additional_options = OS.mac? ? "-J-XstartOnFirstThread" : ""
  spec.ruby_opts = ["#{additional_options} -J-classpath \"#{GlimmerApplication::SWT_JAR_FILE}\" -Xcli.debug=true --debug"]
end

task :default => :spec

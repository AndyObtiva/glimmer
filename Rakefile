require 'rubygems'
require 'bundler'
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
  gem.description = %Q{JRuby DSL that enables easy and efficient authoring of user-interfaces using the robust platform-independent Eclipse SWT library}
  gem.email = "andy.am@gmail.com"
  gem.authors = ["Andy Maleh"]
  gem.executables = ['glimmer']
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'samples' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
  test.ruby_opts = ['-J-XstartOnFirstThread -Xcli.debug=true --debug']
end

task :default => :test

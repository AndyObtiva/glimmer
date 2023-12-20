require 'rubygems'
require 'bundler'
# require 'os'
# require_relative 'lib/glimmer/launcher'
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
    gem.summary = %Q{Glimmer - DSL Framework for Ruby GUI and More}
    gem.description = %Q{Glimmer is a Ruby DSL Framework for Ruby GUI and More, consisting of a DSL Engine and a Data-Binding Library (including Observer Design Pattern, Observable Model, Observable Array, and Observable Hash). Used in Glimmer DSL for SWT (JRuby Desktop Development GUI Framework), Glimmer DSL for Opal (Pure Ruby Web GUI and Auto-Webifier of Desktop Apps), Glimmer DSL for LibUI (Prerequisite-Free Ruby Desktop Development GUI Library and Winner of Fukuoka Ruby Award Competition 2022 Special Award), Glimmer DSL for Tk (Ruby Tk Desktop Development GUI Library), Glimmer DSL for GTK (Ruby-GNOME Desktop Development GUI Library), Glimmer DSL for FX (FOX Toolkit Ruby Desktop Development GUI Library), Glimmer DSL for Swing (JRuby Swing Desktop Development GUI Library), Glimmer DSL for JFX (JRuby JavaFX Desktop Development GUI Library), Glimmer DSL for XML (& HTML), and Glimmer DSL for CSS.}
    gem.email = "andy.am@gmail.com"
    gem.authors = ["AndyMaleh"]
    # gem.executables = ['glimmer', 'girb'] # moved to glimmer-dsl-swt for now
    gem.files = Dir['README.md', 'LICENSE.txt', 'VERSION', 'PROCESS.md', 'CONTRIBUTING.md', 'CHANGELOG.md', 'glimmer.gemspec', 'lib/**/*']
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

  # spec.ruby_opts = ["--profile.graph #{Glimmer::Launcher.jruby_swt_options}"]
  # require 'jruby/profiler'
  # profile_data = JRuby::Profiler.profile do
  # end

#   spec.ruby_opts = [Glimmer::Launcher.jruby_swt_options]
end

task :default => :spec

task :no_puts_debuggerer do
  ENV['puts_debuggerer'] = 'false'
end

namespace :build do
  desc 'Builds without running specs for quick testing, but not release'
  task :prototype => :no_puts_debuggerer do
    Rake::Task['build'].execute
  end
end

Rake::Task["build"].enhance [:no_puts_debuggerer, :spec]

require 'coveralls/rake/task'
Coveralls::RakeTask.new
task :spec_with_coveralls => [:spec] do
  ENV['TRAVIS'] = 'true'
  ENV['CI'] = 'true' if ENV['CI'].nil?
  Rake::Task['coveralls:push'].invoke
end

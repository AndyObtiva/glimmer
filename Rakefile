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
    gem.summary = %Q{Glimmer Ruby DSL Engine}
    gem.description = %Q{Glimmer is a Ruby DSL Framework consisting of a DSL Engine and Observable/Observer/Data-Binding Library. Used in the Glimmer DSL for SWT (JRuby Desktop Development GUI Framework), the Glimmer DSL for Tk (Ruby Desktop Development GUI Library), the Glimmer DSL for Opal (Pure Ruby Web GUI and Auto-Webifier of Desktop Apps), the Glimmer DSL for XML (& HTML), and the Glimmer DSL for CSS.}
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

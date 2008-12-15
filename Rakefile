require 'rake'
require 'rake/testtask'

task :default => 'test_core'

Rake::TestTask.new 'test_core' do |t|
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

desc "Build gemspec for Github (use VERSION=x.x.x to specify glimmer version)"
task 'gemspec' do
  version = ENV["VERSION"] || "0.1.4"
  lib_files = GemHelper.all_files_from_dir('lib').join(" ")
  test_files = GemHelper.all_files_from_dir('test').join(" ")
  sample_files = GemHelper.all_files_from_dir('samples').join(" ")
  gemspec = GemHelper.render_template(GEMSPEC_TEMPLATE, {:version => version, :lib_files => lib_files, :test_files => test_files, :sample_files => sample_files})
  File.open('glimmer.gemspec', 'w') do |file|
    file.write gemspec
  end
  puts "Built glimmer.gemspec with version #{version} - Ready to push to Github now."
end


module GemHelper
  # add all files from one directory
  def self.all_files_from_dir(directory, extension='rb')
    files = Dir["#{directory}/**/*.#{extension}"]
  end
  
  # Render the string template for the GemSpec and insert all files and version no.
  def self.render_template(template, params={})
    rendered_template = template
    params.each do |key, value|
      rendered_template.gsub!(/<%= *\@#{key.to_s.downcase} *%>/, value.to_s)
    end
    return rendered_template
  end
end

GEMSPEC_TEMPLATE = <<-EOS
  VERSION = "<%= @version %>"
  
  lib_files = %w[<%= @lib_files %>]
  test_files = %w[<%= @test_files %>]
  sample_files = %w[<%= @sample_files %>]
  
  Gem::Specification.new do |s|
    s.name = "glimmer"
    s.version = VERSION
    s.date = "2008-12-06"
    s.summary = "JRuby DSL that enables easy and efficient authoring of user-interfaces 
  using the robust platform-independent Eclipse SWT library"
    s.email = "andy@obtiva.com"
    s.homepage = "http://github.com/AndyObtiva/glimmer"
    s.description = "Ruby library for fetching information about games from www.gamefaqs.com using Hpricot"
    s.has_rdoc = true
    s.authors = ["Andy Maleh"]
    s.require_path = "lib"
    s.files = %w[bin/glimmer Rakefile] + lib_files + sample_files
    s.executables = %w[glimmer]
    s.test_files = test_files
    #s.rdoc_options = ["--main", "README"]
    s.extra_rdoc_files = ["README"]
    s.add_dependency("facets", ["> 2.2.0"])
  end

EOS
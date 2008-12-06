VERSION = "0.1.4"

lib_files = %w[]
test_files = %w[]
mock_files = %w[]
 
# add all files from one directory
module Helper
  def self.all_from_dir(dir_name, array, extension=".rb")
    array.map { |file| "#{dir_name}/#{file}#{extension}" }
  end
end
 
Gem::Specification.new do |s|
  s.name = "glimmer"
  s.version = VERSION
  s.date = "2008-12-06"
  s.summary = "JRuby DSL that enables easy and efficient authoring of user-interfaces 
using the robust platform-independent Eclipse SWT library"
  s.email = "soleone@gmail.com"
  s.homepage = "http://github.com/AndyObtiva/glimmer"
  s.description = "Ruby library for fetching information about games from www.gamefaqs.com using Hpricot"
  s.has_rdoc = true
  s.authors = ["Andy Maleh"]
  s.files = ["src/glimmer.rb"] + Helper.all_from_dir("src", lib_files)
  s.test_files = Helper.all_from_dir("test", test_files) + Helper.all_from_dir("test/mocks", mock_files, ".html")
  s.rdoc_options = ["--main", "README.textile"]
  s.extra_rdoc_files = ["README.textile"]
  s.add_dependency("facets", ["> 2.2.0"])
end
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'samples'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'glimmer'

class Test::Unit::TestCase
  def assert_has_style(style, widget)
    assert_equal style, widget.getStyle & style
  end  
end

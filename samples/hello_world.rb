require File.dirname(__FILE__) + "/../lib/glimmer"

include Glimmer

shell {
  text "SWT"
  label {
    text "Hello World!"
  }
}.open

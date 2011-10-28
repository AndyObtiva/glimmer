require File.dirname(__FILE__) + "/glimmer"

class Array
  include Glimmer

  alias original_compare <=>

  def <=>(other)
    if (self[0].class.name == "RWidget")
      add_contents(self[0]) {
        if (other.size == 2)
          eval("#{self[1]} bind (other[0], other[1])")
        elsif (other.size == 3)
          eval("#{self[1]} bind (other[0], other[1], other[2])")
        end
      }
    else
      original_compare(other)
    end
  end
end

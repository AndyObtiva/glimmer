# Mixin representing Observer trait from Observer Design Pattern
# Allows classes to include without interfering with their
# inheritance hierarchy.
# TODO add code for tracking observable to do autocleaning
module Observer
  def update(changed_value)
    raise 'Not implemented!'
  end
end

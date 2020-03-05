# Observer that takes an updater block to process updates

class BlockObserver
  include Observer

  def initialize(&updater)
    @updater = updater
  end


  def update(changed_value)
    puts '>>puts'
    puts changed_value.inspect
    puts changed_value
    pd changed_value
    @updater.call(changed_value)
  end
end

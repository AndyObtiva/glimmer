class RRunnable
  include java.lang.Runnable
  
  def initialize(&block)
    @block = block
  end
  
  def run
    @block.call
  end
end

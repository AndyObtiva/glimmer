require File.dirname(__FILE__) + "/../command_handler"
require File.dirname(__FILE__) + "/models/r_widget"

class SwtConstantCommandHandler
  include CommandHandler
  
  include_package 'org.eclipse.swt'

  def can_handle?(parent, command_symbol, *args, &block)
      args.size == 0 and
      block == nil
  end
  
  def do_handle(parent, command_symbol, *args, &block)
    puts 'org.eclipse.swt.SWT::' + command_symbol.to_s.upcase
    eval 'org.eclipse.swt.SWT::' + command_symbol.to_s.upcase
  end
  
end
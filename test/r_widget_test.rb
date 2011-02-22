require File.dirname(__FILE__) + "/helper"

class RWidgetTest < Test::Unit::TestCase
  include Glimmer

  def setup
    dsl :swt
  end

  def test_async_exec
    @target = shell {
      @text = text {
        text "text1"
      }
    }

    @target.async_exec do 
      @text.widget.setText("text2") 
    end
    
    @target.async_exec do 
      assert_equal "text2", @text.widget.getText
      @target.widget.close
    end
    
    @target.open
  end
  
  def test_sync_exec
    @target = shell {
      @text = text {
        text "text1"
      }
    }

    @target.async_exec do 
      assert_equal "text2", @text.widget.getText
      @text.widget.setText("text3") 
    end
    
    @target.sync_exec do 
      @text.widget.setText("text2") 
    end
    
    @target.async_exec do 
      @target.widget.close
    end
    
    @target.open
  end
  
end
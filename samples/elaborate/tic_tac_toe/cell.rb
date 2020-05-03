class TicTacToe
  class Cell
    EMPTY = ""
    attr_accessor :sign, :empty
  
    def initialize
      reset
    end
  
    def mark(sign)
      self.sign = sign
    end
  
    def reset
      self.sign = EMPTY
    end
  
    def sign=(sign_symbol)
      @sign = sign_symbol
      self.empty = sign == EMPTY
    end
  
    def marked
      !empty
    end
  end
end

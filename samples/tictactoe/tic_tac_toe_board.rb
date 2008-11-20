################################################################################
# Copyright (c) 2008 Annas Al Maleh.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#    Annas Al Maleh - initial API and implementation
################################################################################ 

class TicTacToeBox
  EMPTY = ""
  attr_accessor :sign, :empty
  
  def initialize
    reset
  end

  def mark_box(sign)
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
    ! empty
  end
end

class TicTacToeBoard
  DRAW = :draw
  IN_PROGRESS = :in_progress
  WIN = :win
  attr :winning_sign
  attr_accessor :game_status
  
  def initialize
    @sign_state_machine = {nil => "X", "X" => "O", "O" => "X"}
    build_grid
    @winning_sign = TicTacToeBox::EMPTY
    @game_status = IN_PROGRESS
  end
  
  #row and column numbers are 1-based
  def mark_box(row_number, column_number)
    box(row_number, column_number).mark_box(current_sign)
    game_over? #updates winning sign
  end
  
  def current_sign
    @current_sign = @sign_state_machine[@current_sign]
  end
  
  def box(row_number, column_number)
    @grid[row_number-1][column_number-1]
  end 
  
  def game_over?
     win? or draw?
  end
  
  def win?
    win = (row_win? or column_win? or diagonal_win?)
    self.game_status=WIN if win
    win
  end
  
  def reset
    (1..3).each do |row_number|
      (1..3).each do |column_number|
        box(row_number, column_number).reset
      end
    end
    @winning_sign = TicTacToeBox::EMPTY
    @current_sign = nil
    self.game_status=IN_PROGRESS
  end
  
  private
  
  def build_grid
    @grid = []
    3.times do |row_index| #0-based
      @grid << []
      3.times { @grid[row_index] << TicTacToeBox.new }
    end
  end
  
  def row_win?
    (1..3).each do |row_number| 
      if row_has_same_sign(row_number)
        @winning_sign = box(row_number, 1).sign
        return true
      end
    end
    false
  end
  
  def column_win?
    (1..3).each do |column_number| 
      if column_has_same_sign(column_number)
        @winning_sign = box(1, column_number).sign
        return true
      end
    end
    false
  end

  #needs refactoring if we ever decide to make the board size dynamic
  def diagonal_win?
    if (box(1,1).sign == box(2,2).sign) and (box(2,2).sign == box(3,3).sign) and box(1,1).marked
      @winning_sign = box(1,1).sign
      return true
    end
    if (box(3,1).sign == box(2,2).sign) and (box(2,2).sign == box(1,3).sign) and box(3,1).marked
      @winning_sign = box(3,1).sign
      return true
    end
    false
  end
  
  def draw?
    @board_full = true
    3.times do |x|
      3.times do |y|
        @board_full = false if box(x, y).empty
      end
    end
    self.game_status = DRAW if @board_full
    @board_full
  end
  
  def row_has_same_sign(number) 
    row_sign = box(number, 1).sign
    [2, 3].each do |column|
      return false unless row_sign == (box(number, column).sign)
    end
    true if box(number, 1).marked
  end
 
  def column_has_same_sign(number) 
    column_sign = box(1, number).sign
    [2, 3].each do |row|
      return false unless column_sign == (box(row, number).sign)
    end
    true if box(1, number).marked
  end
 
end

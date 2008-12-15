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

require File.dirname(__FILE__) + "/../../test_helper"
require File.dirname(__FILE__) + "/../../../samples/tictactoe/tic_tac_toe_board"

class TicTacToeTest < Test::Unit::TestCase

  def setup
    @board = TicTacToeBoard.new
  end
  
  def test_mark_center_x
    assert_equal("", @board.box(2, 2).sign)
    @board.mark_box(2, 2)
    assert ! @board.box(2, 2).empty
    assert_equal("X", @board.box(2, 2).sign)
    assert @board.box(1, 1).empty
    assert @board.box(1, 2).empty
    assert @board.box(1, 3).empty
    assert @board.box(2, 1).empty
    assert @board.box(2, 3).empty
    assert @board.box(3, 1).empty
    assert @board.box(3, 2).empty
    assert @board.box(3, 3).empty
  end
  
  def test_mark_center_x_top_center_o_bottom_right_x
    @board.mark_box(2, 2)
    @board.mark_box(1, 2)
    @board.mark_box(3, 3)
    assert ! @board.box(2, 2).empty
    assert ! @board.box(1, 2).empty
    assert ! @board.box(3, 3).empty
    assert_equal("X", @board.box(2, 2).sign)
    assert_equal("O", @board.box(1, 2).sign)
    assert_equal("X", @board.box(3, 3).sign)
  end

  def test_top_center_not_marked
    assert @board.box(1, 2).empty
  end
  
  def test_top_right_marked
    @board.mark_box(1, 3)
    assert ! @board.box(1, 3).empty
  end
  
  def test_lower_right_marked
    @board.mark_box(3, 3)
    assert ! @board.box(3, 3).empty
  end

  def test_game_over_false
    assert ! @board.game_over?
    assert_equal "X", @board.current_sign
    assert_equal TicTacToeBoard::IN_PROGRESS, @board.game_status
  end
  
  def test_game_over_X_wins_top_row_across
    @board.mark_box(1, 1)
    assert_equal("X", @board.box(1, 1).sign)
    @board.mark_box(2, 1)
    assert_equal("O", @board.box(2, 1).sign)
    @board.mark_box(1, 2)
    assert_equal("X", @board.box(1, 2).sign)
    @board.mark_box(2, 2)
    assert_equal("O", @board.box(2, 2).sign)
    @board.mark_box(1, 3)
    assert_equal("X", @board.box(1, 3).sign)
    assert @board.game_over?
    assert_equal "X", @board.winning_sign
    assert_equal TicTacToeBoard::WIN, @board.game_status
  end
  
  def test_game_over_O_wins_top_row_across
    @board.mark_box(2, 1)
    @board.mark_box(1, 1)
    @board.mark_box(2, 2)
    @board.mark_box(1, 2)
    @board.mark_box(3, 3)
    @board.mark_box(1, 3)
    assert @board.game_over?
    assert_equal "O", @board.winning_sign
  end

  def test_game_over_X_wins_second_row_across
    @board.mark_box(2, 1)
    @board.mark_box(1, 1)
    @board.mark_box(2, 2)
    @board.mark_box(1, 2)
    @board.mark_box(2, 3)
    assert @board.game_over?
    assert_equal "X", @board.winning_sign
  end
  
  def test_game_over_O_wins_second_row_across
    @board.mark_box(1, 1)
    @board.mark_box(2, 1)
    @board.mark_box(3, 1)
    @board.mark_box(2, 2)
    @board.mark_box(1, 2)
    @board.mark_box(2, 3)
    assert @board.game_over?
    assert_equal "O", @board.winning_sign
  end
  
  def test_game_over_X_wins_third_row_across
    @board.mark_box(3, 1)
    @board.mark_box(1, 1)
    @board.mark_box(3, 2)
    @board.mark_box(1, 2)
    @board.mark_box(3, 3)
    assert @board.game_over?
    assert_equal "X", @board.winning_sign
  end

  def test_game_over_O_wins_third_row_across
    @board.mark_box(1, 1)
    @board.mark_box(3, 1)
    @board.mark_box(1, 2)
    @board.mark_box(3, 2)
    @board.mark_box(2, 3)
    @board.mark_box(3, 3)
    assert @board.game_over?
  end
 
  def test_game_over_X_wins_first_column_down
    @board.mark_box(1, 1)
    @board.mark_box(2, 2)
    @board.mark_box(2, 1)
    @board.mark_box(3, 2)
    @board.mark_box(3, 1)
    assert @board.game_over?
    assert_equal "X", @board.winning_sign
  end
  
  def test_game_over_O_wins_first_column_down
    @board.mark_box(2, 2)
    @board.mark_box(1, 1)
    @board.mark_box(3, 2)
    @board.mark_box(2, 1)
    @board.mark_box(3, 3)
    @board.mark_box(3, 1)
    assert @board.game_over?
  end
  
  def test_game_over_X_wins_second_column_down
    @board.mark_box(1, 2)
    @board.mark_box(2, 1)
    @board.mark_box(2, 2)
    @board.mark_box(3, 1)
    @board.mark_box(3, 2)
    assert @board.game_over?
    assert_equal "X", @board.winning_sign
  end

  def test_game_over_O_wins_second_column_down
    @board.mark_box(2, 1)
    @board.mark_box(1, 2)
    @board.mark_box(3, 1)
    @board.mark_box(2, 2)
    @board.mark_box(2, 3)
    @board.mark_box(3, 2)
    assert @board.game_over?
    assert_equal "O", @board.winning_sign
  end
  
  def test_game_over_X_wins_third_column_down
    @board.mark_box(1, 3)
    @board.mark_box(2, 1)
    @board.mark_box(2, 3)
    @board.mark_box(3, 1)
    @board.mark_box(3, 3)
    assert @board.game_over?
    assert_equal "X", @board.winning_sign
  end
  
  def test_game_over_O_wins_third_column_down
    @board.mark_box(2, 1)
    @board.mark_box(1, 3)
    @board.mark_box(3, 1)
    @board.mark_box(2, 3)
    @board.mark_box(3, 2)
    @board.mark_box(3, 3)
    assert @board.game_over?
    assert_equal "O", @board.winning_sign
  end
  
  def test_game_over_X_wins_top_left_to_bottom_right
    @board.mark_box(1, 1)
    @board.mark_box(2, 1)
    @board.mark_box(2, 2)
    @board.mark_box(3, 2)
    @board.mark_box(3, 3)
    assert_equal "X", @board.winning_sign
    assert @board.game_over?
  end
  
  def test_game_over_O_wins_top_left_to_bottom_right
    @board.mark_box(2, 1)
    @board.mark_box(1, 1)
    @board.mark_box(3, 2)
    @board.mark_box(2, 2)
    @board.mark_box(2, 3)
    @board.mark_box(3, 3)
    assert_equal "O", @board.winning_sign
    assert @board.game_over?
  end
  
  def test_game_over_X_wins_top_right_to_bottom_left
    @board.mark_box(1, 3)
    @board.mark_box(2, 1)
    @board.mark_box(2, 2)
    @board.mark_box(3, 2)
    @board.mark_box(3, 1)
    assert_equal "X", @board.winning_sign
    assert @board.game_over?
  end

  def test_game_over_O_wins_top_right_to_bottom_left
    @board.mark_box(2, 1)
    @board.mark_box(1, 3)
    @board.mark_box(3, 2)
    @board.mark_box(2, 2)
    @board.mark_box(1, 1)
    @board.mark_box(3, 1)
    assert_equal "O", @board.winning_sign
    assert @board.game_over?
  end

  #   1 2 3
  #1  x o x
  #2  o x x
  #3  o x o
  def test_game_over_draw
    @board.mark_box(1, 1) 
    @board.mark_box(1, 2)
    @board.mark_box(1, 3)
    @board.mark_box(2, 1)
    @board.mark_box(2, 2)
    @board.mark_box(3, 1)
    @board.mark_box(2, 3)
    @board.mark_box(3, 3)
    assert ! @board.game_over?
    @board.mark_box(3, 2)
    assert @board.game_over?
    assert_equal TicTacToeBox::EMPTY, @board.winning_sign
    assert_equal TicTacToeBoard::DRAW, @board.game_status
  end
  
  def test_reset
    @board.mark_box(1, 3)
    @board.mark_box(2, 1)
    @board.mark_box(2, 2)
    @board.mark_box(3, 2)
    @board.mark_box(3, 1)
    @board.reset
    assert ! @board.game_over?
    assert_equal TicTacToeBox::EMPTY, @board.winning_sign
    assert_equal TicTacToeBoard::IN_PROGRESS, @board.game_status
    assert_equal "X", @board.current_sign
  end

end
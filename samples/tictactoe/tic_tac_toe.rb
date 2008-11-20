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

require File.dirname(__FILE__) + "/../../src/swt"
require File.dirname(__FILE__) + "/tic_tac_toe_board"


class TicTacToe
  
  include_package 'org.eclipse.swt'
  include_package 'org.eclipse.swt.widgets'
  include_package 'org.eclipse.swt.layout'
  
  include Glimmer

  def initialize
    @tic_tac_toe_board = TicTacToeBoard.new
    @main = 
    @shell = shell {
      text "Tic-Tac-Toe"
      composite {
        layout GridLayout.new(3,true) 
        (1..3).each { |row_number|
          (1..3).each { |column_number|
            button {
              layout_data GridData.new(fill, fill, true, true)
              text        bind(@tic_tac_toe_board.box(row_number, column_number), :sign)
              enabled     bind(@tic_tac_toe_board.box(row_number, column_number), :empty)
              on_widget_selected {
                @tic_tac_toe_board.mark_box(row_number, column_number)
              }
            }
          }
        }
      }
    }
    @tic_tac_toe_board.extend(ObservableModel) #make board an observable model
    @tic_tac_toe_board.add_observer("game_status", self)
  end
  
  def update(game_status) 
    display_win_message if game_status == TicTacToeBoard::WIN
    display_draw_message if game_status == TicTacToeBoard::DRAW
  end
  
  def display_win_message()
    display_game_over_message("Player #{@tic_tac_toe_board.winning_sign} has won!")
  end
  
  def display_draw_message()
    display_game_over_message("Draw!")
  end
  
  def display_game_over_message(message)
    message_box = MessageBox.new(@shell.widget)
    message_box.setText("Game Over")
    message_box.setMessage(message)
    message_box.open
    @tic_tac_toe_board.reset
  end
  
  def open 
      @main.open
  end
end

TicTacToe.new.open

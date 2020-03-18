require_relative "tic_tac_toe_board"

class TicTacToe
  include Glimmer
  include Observer

  def initialize
    @tic_tac_toe_board = TicTacToeBoard.new
    @main =
    @shell = shell {
      text "Tic-Tac-Toe"
      composite {
        grid_layout 3, true
        (1..3).each { |row|
          (1..3).each { |column|
            button {
              layout_data GSWT[:fill], GSWT[:fill], true, true
              text        bind(@tic_tac_toe_board[row, column], :sign)
              enabled     bind(@tic_tac_toe_board[row, column], :empty)
              on_widget_selected {
                @tic_tac_toe_board.mark_box(row, column)
              }
            }
          }
        }
      }
    }
    observe(@tic_tac_toe_board, :game_status)
  end

  def call(game_status)
    display_win_message if game_status == TicTacToeBoard::WIN
    display_draw_message if game_status == TicTacToeBoard::DRAW
  end

  def display_win_message
    display_game_over_message("Player #{@tic_tac_toe_board.winning_sign} has won!")
  end

  def display_draw_message
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

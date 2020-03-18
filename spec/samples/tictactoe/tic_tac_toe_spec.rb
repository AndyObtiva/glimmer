require "spec_helper"

require_relative "../../../samples/tictactoe/tic_tac_toe_board"

describe TicTacToeBoard do

  before do
    @board = TicTacToeBoard.new
  end

  it "tests mark_center_x" do
    expect(@board[2, 2].sign).to eq("")
    @board.mark_box(2, 2)
    expect(@board[2, 2].empty).to be_false
    expect(@board[2, 2].sign).to eq("X")
    expect(@board[1, 1].empty).to be_true
    expect(@board[1, 2].empty).to be_true
    expect(@board[1, 3].empty).to be_true
    expect(@board[2, 1].empty).to be_true
    expect(@board[2, 3].empty).to be_true
    expect(@board[3, 1].empty).to be_true
    expect(@board[3, 2].empty).to be_true
    expect(@board[3, 3].empty).to be_true
  end

  it "tests mark_center_x_top_center_o_bottom_right_x" do
    @board.mark_box(2, 2)
    @board.mark_box(1, 2)
    @board.mark_box(3, 3)
    expect(@board[2, 2].empty).to be_false
    expect(@board[1, 2].empty).to be_false
    expect(@board[3, 3].empty).to be_false
    expect(@board[2, 2].sign).to eq("X")
    expect(@board[1, 2].sign).to eq("O")
    expect(@board[3, 3].sign).to eq("X")
  end

  it "tests top_center_not_marked" do
    expect(@board[1, 2].empty).to be_true
  end

  it "tests top_right_marked" do
    @board.mark_box(1, 3)
    expect(@board[1, 3].empty).to be_false
  end

  it "tests lower_right_marked" do
    @board.mark_box(3, 3)
    expect(@board[3, 3].empty).to be_false
  end

  it "tests game_over_false" do
    expect(@board.game_over?).to be_false
    expect(@board.current_sign).to eq("X")
    expect(@board.game_status).to eq(TicTacToeBoard::IN_PROGRESS)
  end

  it "tests game_over_X_wins_top_row_across" do
    @board.mark_box(1, 1)
    expect(@board[1, 1].sign).to eq("X")
    @board.mark_box(2, 1)
    expect(@board[2, 1].sign).to eq("O")
    @board.mark_box(1, 2)
    expect(@board[1, 2].sign).to eq("X")
    @board.mark_box(2, 2)
    expect(@board[2, 2].sign).to eq("O")
    @board.mark_box(1, 3)
    expect(@board[1, 3].sign).to eq("X")
    expect(@board.game_over?).to be_true
    expect(@board.winning_sign).to eq("X")
    expect(@board.game_status).to eq(TicTacToeBoard::WIN)
  end

  it "tests game_over_O_wins_top_row_across" do
    @board.mark_box(2, 1)
    @board.mark_box(1, 1)
    @board.mark_box(2, 2)
    @board.mark_box(1, 2)
    @board.mark_box(3, 3)
    @board.mark_box(1, 3)
    expect(@board.game_over?).to be_true
    expect(@board.winning_sign).to eq("O")
  end

  it "tests game_over_X_wins_second_row_across" do
    @board.mark_box(2, 1)
    @board.mark_box(1, 1)
    @board.mark_box(2, 2)
    @board.mark_box(1, 2)
    @board.mark_box(2, 3)
    expect(@board.game_over?).to be_true
    expect(@board.winning_sign).to eq("X")
  end

  it "tests game_over_O_wins_second_row_across" do
    @board.mark_box(1, 1)
    @board.mark_box(2, 1)
    @board.mark_box(3, 1)
    @board.mark_box(2, 2)
    @board.mark_box(1, 2)
    @board.mark_box(2, 3)
    expect(@board.game_over?).to be_true
    expect(@board.winning_sign).to eq("O")
  end

  it "tests game_over_X_wins_third_row_across" do
    @board.mark_box(3, 1)
    @board.mark_box(1, 1)
    @board.mark_box(3, 2)
    @board.mark_box(1, 2)
    @board.mark_box(3, 3)
    expect(@board.game_over?).to be_true
    expect(@board.winning_sign).to eq("X")
  end

  it "tests game_over_O_wins_third_row_across" do
    @board.mark_box(1, 1)
    @board.mark_box(3, 1)
    @board.mark_box(1, 2)
    @board.mark_box(3, 2)
    @board.mark_box(2, 3)
    @board.mark_box(3, 3)
    expect(@board.game_over?).to be_true
  end

  it "tests game_over_X_wins_first_column_down" do
    @board.mark_box(1, 1)
    @board.mark_box(2, 2)
    @board.mark_box(2, 1)
    @board.mark_box(3, 2)
    @board.mark_box(3, 1)
    expect(@board.game_over?).to be_true
    expect(@board.winning_sign).to eq("X")
  end

  it "tests game_over_O_wins_first_column_down" do
    @board.mark_box(2, 2)
    @board.mark_box(1, 1)
    @board.mark_box(3, 2)
    @board.mark_box(2, 1)
    @board.mark_box(3, 3)
    @board.mark_box(3, 1)
    expect(@board.game_over?).to be_true
  end

  it "tests game_over_X_wins_second_column_down" do
    @board.mark_box(1, 2)
    @board.mark_box(2, 1)
    @board.mark_box(2, 2)
    @board.mark_box(3, 1)
    @board.mark_box(3, 2)
    expect(@board.game_over?).to be_true
    expect(@board.winning_sign).to eq("X")
  end

  it "tests game_over_O_wins_second_column_down" do
    @board.mark_box(2, 1)
    @board.mark_box(1, 2)
    @board.mark_box(3, 1)
    @board.mark_box(2, 2)
    @board.mark_box(2, 3)
    @board.mark_box(3, 2)
    expect(@board.game_over?).to be_true
    expect(@board.winning_sign).to eq("O")
  end

  it "tests game_over_X_wins_third_column_down" do
    @board.mark_box(1, 3)
    @board.mark_box(2, 1)
    @board.mark_box(2, 3)
    @board.mark_box(3, 1)
    @board.mark_box(3, 3)
    expect(@board.game_over?).to be_true
    expect(@board.winning_sign).to eq("X")
  end

  it "tests game_over_O_wins_third_column_down" do
    @board.mark_box(2, 1)
    @board.mark_box(1, 3)
    @board.mark_box(3, 1)
    @board.mark_box(2, 3)
    @board.mark_box(3, 2)
    @board.mark_box(3, 3)
    expect(@board.game_over?).to be_true
    expect(@board.winning_sign).to eq("O")
  end

  it "tests game_over_X_wins_top_left_to_bottom_right" do
    @board.mark_box(1, 1)
    @board.mark_box(2, 1)
    @board.mark_box(2, 2)
    @board.mark_box(3, 2)
    @board.mark_box(3, 3)
    expect(@board.winning_sign).to eq("X")
    expect(@board.game_over?).to be_true
  end

  it "tests game_over_O_wins_top_left_to_bottom_right" do
    @board.mark_box(2, 1)
    @board.mark_box(1, 1)
    @board.mark_box(3, 2)
    @board.mark_box(2, 2)
    @board.mark_box(2, 3)
    @board.mark_box(3, 3)
    expect(@board.winning_sign).to eq("O")
    expect(@board.game_over?).to be_true
  end

  it "tests game_over_X_wins_top_right_to_bottom_left" do
    @board.mark_box(1, 3)
    @board.mark_box(2, 1)
    @board.mark_box(2, 2)
    @board.mark_box(3, 2)
    @board.mark_box(3, 1)
    expect(@board.winning_sign).to eq("X")
    expect(@board.game_over?).to be_true
  end

  it "tests game_over_O_wins_top_right_to_bottom_left" do
    @board.mark_box(2, 1)
    @board.mark_box(1, 3)
    @board.mark_box(3, 2)
    @board.mark_box(2, 2)
    @board.mark_box(1, 1)
    @board.mark_box(3, 1)
    expect(@board.winning_sign).to eq("O")
    expect(@board.game_over?).to be_true
  end

  #   1 2 3
  #1  x o x
  #2  o x x
  #3  o x o
  it "tests game_over_draw" do
    @board.mark_box(1, 1)
    @board.mark_box(1, 2)
    @board.mark_box(1, 3)
    @board.mark_box(2, 1)
    @board.mark_box(2, 2)
    @board.mark_box(3, 1)
    @board.mark_box(2, 3)
    @board.mark_box(3, 3)
    expect(@board.game_over?).to be_false
    @board.mark_box(3, 2)
    expect(@board.game_over?).to be_true
    expect(@board.winning_sign).to eq(TicTacToeBox::EMPTY)
    expect(@board.game_status).to eq(TicTacToeBoard::DRAW)
  end

  it "tests reset" do
    @board.mark_box(1, 3)
    @board.mark_box(2, 1)
    @board.mark_box(2, 2)
    @board.mark_box(3, 2)
    @board.mark_box(3, 1)
    @board.reset
    expect(@board.game_over?).to be_false
    expect(@board.winning_sign).to eq(TicTacToeBox::EMPTY)
    expect(@board.game_status).to eq(TicTacToeBoard::IN_PROGRESS)
    expect(@board.current_sign).to eq("X")
  end

end

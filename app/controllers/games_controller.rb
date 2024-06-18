class GamesController < ApplicationController
  def new
    @game = Game.new
    
  end

  def create
    board_size = params[:game][:board_size].to_i
    number_range = params[:game][:number_range].to_i
    initial_board = Array.new(board_size) { Array.new(board_size, nil) }

    @game = Game.new(game_params.merge(board: initial_board.to_json, board_size: board_size, number_range: number_range))

    if @game.save
      redirect_to @game
    else
      render :new
    end
  end

  def show
    @game = Game.find(params[:id])
    @board = @game.board_array
     render 'game'
  end

  def update
    @game = Game.find(params[:id])
    row, col, number = params[:row].to_i, params[:col].to_i, params[:number].to_i

    if @game.place_number(row, col, number)
      redirect_to @game
    else
      @board = @game.board_array
      # render :show
      render 'game'
    end
  end

  private

  def game_params
    params.require(:game).permit(:board_size, :number_range, :board, :score)
  end
end

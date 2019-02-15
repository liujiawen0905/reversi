defmodule Reversi.game do

  # generate initial game state
  def init do
      %{
        board: init_board(), 
        on_going: true, 
        current_player: "black"
      }
  end

  def client_view(game) do
    %{board: game[:board], on_going: game[:on_going]}
  end

  #generate initial board (8x8) [[]*8]
  #each element in board is a %{x:x_position, y:y_position, color: player_color}
  #player_color is one of "", "black", "white"
  def init_board() do
    board=[]
  end

  #when user click a button this method should be triggered
  def click(game, x, y) do
    color = game.current_player
    #1)check if button's color is "" (button has not been clicked)
    #2)call flip(game.board, x, y) to generate a new board
    new_board = flip(game.board, x, y, color)
    #3)check if game ends
    new_on_going = not check_finished(new_board)
    #4)update game state (board, next_player, on_going)
    game
    |> Map.put(:board, new_board)
    |> Map.put(:on_going, new_on_going)
    |> Map.put(:current_player, next_player(game.current_player))  
  end

  defp next_player("black") do
    "white"
  end

  defp next_player("white") do
    "black"
  end

  #flip grids and generate a new board
  defp flip(board, x, y, color) do
    board
  end


end





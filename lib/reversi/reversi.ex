defmodule Reversi.game do

  # generate initial game state
  def init do
      state = %{
        board: init_board(),
        on_going: true,
        current_player: "black"
      }
  end

  def client_view(game) do
    %{
      board: game[:board],
      on_going: game[:on_going],
    }
  end

  #generate initial board (8x8) [[]*8]
  #each element in board is a %{x:x_position, y:y_position, color: player_color}
  #player_color is one of "", "black", "white"
  def init_board() do
    xy = [0, 1, 2, 3, 4, 5, 6, 7]
    cells = Enum.map(xy, fn(a) ->
      Enum.map(xy, fn(b) -> %{x: a, y: b, color: ""} end) end)
    Map.put(state, :board, cells)
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
    row = Enum.at(board, x)
    cell = Enum.at(row , y)
    newRow = List.replace_at(row, y, %{x: x, y: y, color: color})
    newBoard = List.replace(board, x, newRow)
    Map.put(state, :board, newBoard)
  end

  defp check_finished(board) do
    check_list = Enum.map(board, fn(row) ->
      Enum.find(row, 0,fn(map) -> map[:color] == "" end) end)

      if Enum.all?(check_list, fn(x) -> x == 0 end) do
        true
      else
        false
      end
  end
end

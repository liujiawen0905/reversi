defmodule Reversi.Game do

  # generate initial game state
  def init do
    %{
      board: init_board(),
      on_going: true,
      current_player: "black",
      players: [],
      spectators: [],
      winner: ""
      }
  end

  def client_view(game) do
    %{
      board: game[:board],
      on_going: game[:on_going],
      current_player: game.current_player,
      players: game.players,
      spectators: game.spectators,
      winner: game.winner
    }
  end

  def spectator_join(game, name) do
    if not Enum.any?(game.spectators, fn x-> x.name==name end) do
      new_list = game.spectators ++ [%{name: name}]
      game = Map.put(game, :spectators, new_list)
      game
    else
      game
    end
  end

  def player_join(game, player_name) do
    if game.players==[] do
      Map.put(game, :players, [%{name: player_name, color: "black"}])
    else
      color = next_player(hd(game.players).color)
      Map.put(game, :players, game.players++[%{name: player_name, color: color}])
    end
  end

  def player_leave(game, name) do
    new_players = Enum.filter(game.players, fn x -> x.name != name end)
    new_game=init()
    new_game
    |> Map.put(:players, new_players)
    |> Map.put(:spectators, game.spectators)
  end

  def spectator_leave(game, name) do
    temp = Enum.filter(game.spectators, fn x -> x.name != name end)
    Map.put(game, :spectators, temp)
  end

  #generate initial board (8x8) [[]*8]
  #each element in board is a %{x:x_position, y:y_position, color: player_color}
  #player_color is one of "", "black", "white"
  def init_board() do
    xy = [0, 1, 2, 3, 4, 5, 6, 7]
    cells = Enum.map(xy, fn(a) ->
      Enum.map(xy, fn(b) ->
        cond do
          (a==3 and b==4) or (a==4 and b==3) ->
            %{x: a, y: b, color: "black"}
          (a==3 and b==3) or (a==4 and b==4) ->
            %{x: a, y: b, color: "white"}
          true ->
            %{x: a, y: b, color: ""}
        end
      end)
    end)
    cells
  end

  #when user click a button this method should be triggered
  def click(game, x, y) do
    if get_grid(game.board, x, y).color == "" and valid_move(game, x, y) do
      color = game.current_player
      #1)check if button's color is "" (button has not been clicked)
      #2)call flip(game.board, x, y) to generate a new board
      #3)add current chess to the board
      flips = get_flips(game.board, x, y, color)
      new_board = flip_all(flips, game.board)
      new_board = add_chess(new_board, x, y, color)
      #3)check if game ends
      #4)update game state (board, next_player, on_going)
      game
      |> Map.put(:board, new_board)
      |> Map.put(:current_player, next_player(game.current_player))
      |> Map.put(:winner, get_winner(game))
      |> Map.put(:on_going, game.winner=="")
    else
      if not can_move(game) do
        game
        |> Map.put(:on_going, false)
        |> Map.put(:winner, next_player(game.current_player))
      else
        game
      end
    end
  end

  def valid_move(game, x, y) do
    length(get_flips(game.board, x, y, game.current_player)) > 0
  end

  def add_chess(board, x, y, color) do
    row = Enum.at(board, x)
    newRow = List.replace_at(row, y, %{x: x, y: y, color: color})
    newBoard = List.replace_at(board, x, newRow)
    newBoard
  end

  def next_player("black") do
    "white"
  end

  def next_player("white") do
    "black"
  end

  #get all grids that need to be flipped
  def get_flips(board, x, y, color) do
    posn=%{x: x, y: y}
    waiting_list=[]
    waiting_list
    #check right
    |> Enum.concat(flip_helper(board, [], %{x: 1, y: 0}, posn, color))
    #check left
    |> Enum.concat(flip_helper(board, [], %{x: -1, y: 0}, posn, color))
    #check top
    |> Enum.concat(flip_helper(board, [], %{x: 0, y: 1}, posn, color))
    #check bottom
    |> Enum.concat(flip_helper(board, [], %{x: 0, y: -1}, posn, color))
    #check top-right
    |> Enum.concat(flip_helper(board, [], %{x: 1, y: 1}, posn, color))
    #check top-left
    |> Enum.concat(flip_helper(board, [], %{x: 1, y: -1}, posn, color))
    #check down-right
    |> Enum.concat(flip_helper(board, [], %{x: -1, y: 1}, posn, color))
    #check down-left
    |> Enum.concat(flip_helper(board, [], %{x: -1, y: -1}, posn, color))
  end

  def flip_all(wl, board) do
    new_board = board
    Enum.map(new_board, fn col ->
      Enum.map(col, fn cell ->
        if cell in wl do
          Map.put(cell, :color, next_player(cell.color))
        else
          cell
        end
      end)
    end)
  end

  #check if this position is within the board
  def in_bound(posn) do
    posn.x>=0 and posn.x<8 and posn.y>=0 and posn.y<7
  end

  def get_grid(board, x, y) do
    board
    |> Enum.at(x)
    |> Enum.at(y)
  end

  #move is where the player placed a new chess (%{x, y})
  #direc represents which direction we are checking along (ex: {x:1, y:1} means top right)
  #posn is the position we will be checking next
  def flip_helper(board, acc, dir, posn, color) do
    #have not find a same-color grid in this direction
    posn = %{x: posn.x+dir.x, y: posn.y+dir.y}
    if not in_bound(posn) do
      []
    else
      target = get_grid(board, posn.x, posn.y)
      cond do
        #met a same color tile, acc contains all grids that need to be flipped in this direction
        target.color==color ->
          acc
        #met an empty tile along the way, stop searching
        target.color=="" ->
          []
        #met opponent's tile, add it to the waiting list
        true ->
          flip_helper(board, acc++[target], dir, posn, color)
      end
    end
  end

  # count number of grid in given color
  def count_color(board, color) do
    Enum.reduce(board, 0, fn row, acc -> acc +   
      Enum.reduce(row, 0, fn x, acc ->  
        if x.color==color do
          acc + 1
        else 
          acc
        end
      end)
    end)
  end

  def full_board(board) do
    all=Enum.concat(board);
    not Enum.any?(all, fn x -> x.color == "" end)
  end

  #return "" if there is no winner
  #return winner's name if there is one
  def get_winner(game) do
    cond do
      full_board(game.board) ->
        black= count_color(game.board, "black")
        white = count_color(game.board, "white")
        if black > white do
          "black"
        else
          "white"
        end
      true ->
        ""
    end
  end

  #check if this user can place a chess on the board
  def can_move(game) do
    all = Enum.concat(game.board)
    Enum.any?(all, fn item -> valid_move(game, item.x, item.y) end)
  end

end






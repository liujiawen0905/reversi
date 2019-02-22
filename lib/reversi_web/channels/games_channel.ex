defmodule ReversiWeb.GamesChannel do
  use ReversiWeb, :channel

  alias Reversi.Game
  alias Reversi.GameServer

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      GameServer.start(name)
      game=GameServer.get_state(name)

      %{"user"=> user_name}=payload
      if length(game.players)<2 do
        IO.puts("user join----------")
        GameServer.user_join(name, "player", user_name)
      else
        IO.puts("spect join---------")
        GameServer.user_join(name, "spectator", user_name)
      end
      game=GameServer.get_state(name)
      socket=socket
      |>assign(:name, name)
      |>assign(:game, game)

      send(self, {:brcast_join, game})
      {:ok, %{"join"=> name, "game"=> Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info({:brcast_join, game}, socket) do
    broadcast socket, "update", game
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  def handle_in("click", %{"x"=> x, "y"=> y}, socket) do
    name=socket.assigns[:name]
    x=String.to_integer(x)
    y=String.to_integer(y)
    new_game=GameServer.click(name, x, y)
    broadcast socket, "update", new_game
    socket=assign(socket, :game, new_game)
    {:reply, {:ok, %{game: Game.client_view(new_game)}}, socket}
  end

  def handle_in("reset", _payload, socket) do
    name=socket.assigns[:name]
    game=GameServer.reset(name)
    {:reply, {:ok, %{game: Game.client_view(game)}}, socket}
  end

  #when a user leave
  #payload is %{"type": "player/spectator", "user_name": name}
  def handle_in("leave", %{"type"=> type, "user"=> user_name}, socket) do
    game=socket.assigns[:game]
    name=socket.assigns[:name]
    if type == "player" do
      IO.puts("player leave")
      game= GameServer.user_leave(name, "player", user_name)
      broadcast socket, "update", game
      {:stop, :shutdown, socket}
    else
      game=GameServer.user_leave(name, "spectator", user_name)
      broadcast socket, "update", game
      {:stop, :shutdown, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end

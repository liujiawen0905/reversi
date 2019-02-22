defmodule Reversi.GameServer do
  use GenServer

  alias Reversi.Backup
  alias Reversi.Game

  def start(name) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :permanent,
      type: :worker,
    }
    Reversi.GameSup.start_child(spec)
  end

  def reg(name) do
    {:via, Registry, {Reversi.GameReg, name}}
  end

  def start_link(name) do
    state = Backup.get(name) || Reversi.Game.init()
    Backup.put(name, state)
    GenServer.start_link(__MODULE__, state, name: reg(name))
  end

  def get_state(name) do
    GenServer.call(reg(name), :get_state)
  end

  def reset(name) do
    GenServer.call(reg(name), {:reset, name})
  end

  def user_join(name, type, user_name) do
    GenServer.call(reg(name), {:user_join, name, type, user_name})
  end

  def user_leave(name, type, user_name) do
    GenServer.call(reg(name), {:user_leave, name, type, user_name})
  end

  def click(name, x, y) do
    GenServer.call(reg(name), {:click, name, x, y})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:get_state, _from, states) do
    {:reply, states, states}
  end

  def handle_call({:reset, name}, _from, states) do
    game=Game.init()
    |> Map.put(:players, states.players)
    |> Map.put(:spectators, states.spectators)
    Backup.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:user_join, name, "player", user_name}, _from, states) do
    state=Game.player_join(states, user_name)
    Backup.put(name, state)
    {:reply, state, state}
  end

  def handle_call({:user_join, name, "spectator", user_name}, _from, states) do
    state=Game.spectator_join(states, user_name)
    Backup.put(name, state)
    {:reply, state, state}
  end

  def handle_call({:user_leave, name, "player", user_name}, _from, states) do
    state=Game.player_leave(states, user_name)
    IO.inspect(state.players)
    Backup.put(name, state)
    {:reply, state, state}
  end

  def handle_call({:user_leave, name, "spectator", user_name}, _from, states) do
    state=Game.spectator_leave(states, user_name)
    IO.inspect(state.players)
    Backup.put(name, state)
    {:reply, state, state}
  end

  def handle_call({:click, name, x, y}, _from, states) do
    state = Reversi.Game.click(states, x, y)
    Backup.put(name, state)
    {:reply, state, state}
  end


end

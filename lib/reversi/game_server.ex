defmodule Reversi.GameServer do
  use GenServer
 
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
    state = Reversi.Game.init()
    GenServer.start_link(__MODULE__, state, name: reg(name))
  end

  def get_state(name) do
    GenServer.call(reg(name), :get_state)
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

  def handle_call({:click, name, x, y}, _from, states) do
    state = Reversi.Game.click(states, x, y)
    {:reply, state, state}
  end


end


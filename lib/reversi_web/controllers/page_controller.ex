defmodule ReversiWeb.PageController do
  use ReversiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def game(conn, {%"name"=>name}) do
    render conn, "reversi.html"
  end
end

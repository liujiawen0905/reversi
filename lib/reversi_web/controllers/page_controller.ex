defmodule ReversiWeb.PageController do
  use ReversiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def game(conn, %{"name"=> name, "user"=> user}) do
    render conn, "reversi.html", name: name, user: user
  end
end

defmodule WalletsWeb.UserController do
  use WalletsWeb, :controller

  def index(conn, _params) do
    json(conn, [%{id: "1"}, %{id: "2"} ])
  end

  def show(conn, %{"id" => id}) do
    json(conn, %{id: id})
  end
end


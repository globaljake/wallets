defmodule WalletsWeb.PageController do
  use WalletsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
# defmodule WalletsWeb.UserController do
#   use WalletsWeb, :controller

#   def index(conn, _params) do
#     render(conn, "index.html")
#   end
# end
# defmodule WalletsWeb.WalletController do
#   use WalletsWeb, :controller

#   def index(conn, _params) do
#     render(conn, "index.html")
#   end
#   def show(conn, _params) do
#     render(conn, "index.html")
#   end
# end

defmodule WalletsWeb.Plugs.Auth do
  @moduledoc """
  Provides user authentication-related plugs and other helper functions.
  """

  import Plug.Conn

  @doc """
  """
  def fetch_current_user_by_session(conn, _opts \\ []) do
    put_current_user(conn, "user-jake")
    # case conn.assigns[:current_user] do
    #   %User{} = _user ->
    #     # This makes testing with auth easier
    #     conn

    #   _ ->
    #     case fetch_remote_user(conn) do
    #       nil -> send_unauthorized(conn, "")
    #       user -> put_current_user(conn, user)
    #     end
    # end
  end

  defp put_current_user(conn, user) do
    conn
    |> assign(:current_user, user)
  end

  # defp send_unauthorized(conn, body) do
  #   conn
  #   |> send_resp(401, body)
  #   |> halt()
  # end
end

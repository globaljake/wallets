defmodule WalletsWeb.Plugs.Absinthe do
  @moduledoc """
  A plug for establishing absinthe context.
  """

  # alias Wallets.Sync.User
  alias WalletsWeb.Schema.Loaders

  @doc """
  Sets absinthe context on the given connection.
  """
  def put_absinthe_context(conn, _) do
    current_user = conn.assigns[:current_user]
    Absinthe.Plug.put_options(conn, context: build_context(current_user))
  end

  defp build_context(String = user) do
    %{current_user: user, loader: build_loader(%{current_user: user})}
  end

  defp build_context(_) do
    %{}
  end

  defp build_loader(params) do
    Dataloader.new()
    |> Dataloader.add_source(:db, Loaders.database_source(params))
  end
end
i
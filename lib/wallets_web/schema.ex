defmodule WalletsWeb.Schema do
  @moduledoc false

  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

#   alias CreatorWeb.Schema.ContentResolvers

  import_types Absinthe.Type.Custom
#   import_types CreatorWeb.Schema.Types

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  query do
    # @desc "The currently authenticated user."
    # field :viewer, :user do
    #   resolve fn _, %{context: %{current_user: current_user}} ->
    #     {:ok, current_user}
    #   end
    # end

    # @desc "A list of videos and galleries."
    # connection field :posts, node_type: :post do
    #   arg :filter, :post_filter
    #   arg :order_by, :post_order

    #   resolve &ContentResolvers.posts/2
    # end
  end
end

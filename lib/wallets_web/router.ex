defmodule WalletsWeb.Router do
  use WalletsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, false
  end
 
  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", WalletsWeb do
    pipe_through :api

    resources("/users", UserController, only: [:show, :index])
  end

  scope "/", WalletsWeb do
    pipe_through :browser

    get("/*path", PageController, :index)
  end

  
end

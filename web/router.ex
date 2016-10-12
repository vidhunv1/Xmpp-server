defmodule Spotlight.Router do
  use Spotlight.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1", Spotlight do
    pipe_through :api

    resources "/users", UserController, only: [:create, :show, :update, :get]
    post "/users/verify", UserController, :verify
  end
end

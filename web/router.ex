defmodule Spotlight.Router do
  use Spotlight.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  pipeline :require_auth do
  end

  scope "/v1", Spotlight do
    pipe_through :api

    resources "/users", UserController, only: [:create, :show, :get]
    post "/users/verify", UserController, :verify
    put "/users/", UserController, :update
    patch "/users/", UserController, :update
  end
end
  

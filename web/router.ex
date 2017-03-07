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

    post "/users", UserController, :create
    post "/users/verify", UserController, :verify
    put "/users", UserController, :update
    patch "/users", UserController, :update
    get "/users/:id", UserController, :show

    resources "/contacts", PhoneContactController, only: [:create]

    post "/bot", BotController, :init
    get "/bot/:username", BotController, :show
    post "/bot/menu", BotController, :update_persistent_menu

    post "/message", MessageController, :send_message
  end
end
  

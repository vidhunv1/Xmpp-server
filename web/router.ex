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
    post "/users/login", UserController, :login
    post "/users/verify", UserController, :verify
    put "/users", UserController, :update
    get "/users/username/:username", UserController, :show
    get "/users/id/:user_id", UserController, :show
    get "/users/logout", UserController, :logout

    resources "/contacts", PhoneContactController, only: [:create]

    post "/bot", BotController, :init
    get "/bot/:username", BotController, :show
    post "/bot/menu", BotController, :update_persistent_menu

    post "/message", MessageController, :send_message

    get "/app/init", AppController, :init

    post "/payment", PaymentsController, :create
    get "/payment/:transaction_id", PaymentsController, :get
  end
end

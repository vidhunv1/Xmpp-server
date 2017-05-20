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

    post "/contacts/phone", PhoneContactController, :create
    get "/contacts/phone/:phone_number", PhoneContactController, :show
    get "/contacts/phone", PhoneContactController, :show

    post "/bot", BotController, :init
    get "/bot/:username", BotController, :show
    post "/bot/menu", BotController, :update_persistent_menu

    post "/message", MessageController, :send_message
    put "/message/image", MessageController, :upload_image
    put "/message/audio", MessageController, :upload_audio

    get "/app/init", AppController, :init
    get "/app/version/:platform", AppController, :app_version

    post "/payment", PaymentsController, :create
    get "/payment/:transaction_id", PaymentsController, :get
    post "/payment/transaction", PaymentsController, :transaction

    get "/contacts/add/:user_id", ContactsController, :add
    get "/contacts/get", ContactsController, :get
    get "/contacts/block/:user_id", ContactsController, :block
    get "/contacts/unblock/:user_id", ContactsController, :unblock
    get "/contacts/suggestions", ContactsController, :get_contact_suggestions
  end
end

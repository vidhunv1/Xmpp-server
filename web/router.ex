defmodule Spotlight.Router do
  use Spotlight.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Spotlight do
    pipe_through :api
  end
end

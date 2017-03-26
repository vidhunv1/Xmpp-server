defmodule Spotlight.AppController do
  use Spotlight.Web, :controller
  require Logger
  import Ecto.Query

  alias Spotlight.Bot

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:init]

  def init(conn, %{}) do
  	user = Guardian.Plug.current_resource(conn)

    init_bots = Bot |> where([b], b.should_app_init_hook==true) |> Repo.all

    Enum.each init_bots, fn bot ->
      case BotHelper.send_app_init(user.user_id, user.name, user.phone, bot.post_url) do
        {:ok, _} ->
          #Message Delivered
          Logger.info("Delivered APP_INIT_HOOK to #{bot.post_url}.")
        {:error, m} ->
          #Error sending message
          Logger.debug("Error APP_INIT_HOOK to #{bot.post_url}. #{m}")
      end
    end
    conn
      |> put_status(:ok)
      |> render("status.json", %{message: "App initialized.", status: "success"})
  end
end

defmodule Spotlight.BotController do
  use Spotlight.Web, :controller
  require Logger

  alias Spotlight.User
  alias Spotlight.Bot

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:init, :get]

  def init(conn, %{"bot" => bot_params}) do
  	user = Guardian.Plug.current_resource(conn)
    bot_user = Repo.preload(user, :bot_details)

  	changeset = user |> Ecto.build_assoc(:bot_details) |> Bot.changeset(bot_params)
  	case Repo.insert(changeset) do
      {:ok, bot_details} ->
        conn
        |> put_status(:created)
        |> render("show.json", %{user: user, bot_details: bot_details})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
      end
  end

  def show(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    bot_user = Repo.preload(user, :bot_details)
    render(conn, "show.json", %{user: bot_user})
  end
end
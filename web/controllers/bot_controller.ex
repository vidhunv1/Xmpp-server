defmodule Spotlight.BotController do
  use Spotlight.Web, :controller
  require Logger

  alias Spotlight.User
  alias Spotlight.Bot
  alias Spotlight.ErrorView

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:init, :get, :update_persistent_menu]

  def init(conn, %{"bot" => bot_params}) do
  	user = Guardian.Plug.current_resource(conn)
    IO.inspect(user)
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

  def update_persistent_menu(conn, %{"persistent_menu" => menu}) do
    user = Guardian.Plug.current_resource(conn)
    bot_user = Repo.preload(user, :bot_details)

    menu_json = Poison.encode!(menu)
    bot_changes  =  %{"persistent_menu" => menu_json}
    changeset = bot_user.bot_details |> Bot.menu_changeset(bot_changes)

    case Repo.update(changeset) do
      {:ok, bot_details} ->
        conn
          |> put_status(:ok)
          |> json(menu)
      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"username" => username}) do
    user = Repo.get_by(User, [username: username])
    bot_user = Repo.preload(user, :bot_details)
    if(!is_nil(bot_user) && !is_nil(bot_user.bot_details)) do
      render(conn, "show.json", %{user: bot_user})
    else
      conn
        |> put_status(200)
        |> render(ErrorView, "error.json", %{message: "user/bot not found", code: "404"})
    end
  end
end
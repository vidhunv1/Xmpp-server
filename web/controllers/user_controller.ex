defmodule Spotlight.UserController do
  use Spotlight.Web, :controller

  alias Spotlight.User

  def create(conn, %{"user" => %{"phone" => phone, "country_code" => country_code}}) do

    user_params = %{"phone" => phone, "country_code" => country_code, "phone_formatted" => country_code<>phone}
    changeset = User.create_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render("show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.update_changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
    end
  end
end

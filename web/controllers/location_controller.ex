defmodule Spotlight.LocationController do
  use Spotlight.Web, :controller
  require Logger
  import Ecto.Query

  alias Spotlight.Location
  alias Spotlight.User

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:update, :get_nearby_people, :delete]

  def update(conn, %{"latitude" => latitude, "longitude" => longitude}) do
    user = Guardian.Plug.current_resource(conn)
    case insert_or_update(user, %{"latitude"=> latitude, "longitude"=> longitude}) do
      {:ok, user} ->
        send_resp(conn, :ok, "")
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def get_nearby_people(conn, %{"latitude" => latitude, "longitude" => longitude}) do
    user = Guardian.Plug.current_resource(conn)
    case insert_or_update(user, %{"latitude"=> latitude, "longitude"=> longitude}) do
      {:ok, user} ->
        query = from l in Location,
          inner_join: u in User, on: l.user_id == u.id and u.id != ^user.id,
          order_by: fragment("d asc"),
          select: %{distance: fragment("distance(?,?,?,?)*1.60934 AS d", l.latitude, l.longitude, ^latitude, ^longitude), latitude: l.latitude, longitude: l.longitude, user: u}
        conn
          |> put_status(200)
          |> render("show_nearby.json", %{nearby: Repo.all(query)})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{}) do
    user = Guardian.Plug.current_resource(conn)
    Repo.get_by(Location, [user_id: user.id]) |> Repo.delete
    send_resp(conn, :ok, "")
  end

  defp insert_or_update(user, %{"latitude"=> latitude, "longitude"=> longitude}) do
    user = user |> Repo.preload(:location)
    if(is_nil(user.location)) do
      changeset = user |> Ecto.build_assoc(:location) |> Location.changeset(%{"latitude"=> latitude, "longitude"=> longitude})
      Repo.insert(changeset)
    else
      changeset = user.location |> Location.changeset(%{"latitude"=> latitude, "longitude"=> longitude})
      Repo.update(changeset)
    end
  end
end

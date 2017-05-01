defmodule Spotlight.MessageController do
  use Spotlight.Web, :controller
  require Logger

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:send_message, :upload_image]

  def send_message(conn, %{"recipient" => to, "message" => message}) do
  	user = Guardian.Plug.current_resource(conn)
    if(!is_nil(user)) do
      from_username = user.username
      to_username = "u_"<>to
      MessageRouter.send_message(from_username, to_username, Poison.encode!(message))
      send_resp(conn, :ok, "")
    else
      send_resp(conn, 401, "Could not find user.")
    end
  end

  def upload_image(conn, %{"image" => image_data}) do
    user = Guardian.Plug.current_resource(conn)
    changeset = user |> Ecto.build_assoc(:message_data) |> Spotlight.MessageData.create_data(%{"data" => image_data, "data_type" => "image"})
    case Repo.insert(changeset) do
      {:ok, mi} ->
        conn
        |> put_status(:ok)
        |> render(Spotlight.MessageDataView, "message_image.json", %{user: user, image: mi.data})
      {:error, changeset} ->
        Logger.debug inspect(changeset)
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
    end
  end
end

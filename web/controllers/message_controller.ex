defmodule Spotlight.MessageController do
  use Spotlight.Web, :controller
  require Logger

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:send_message, :upload_image, :upload_audio]

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
    file_extension = Path.extname(image_data.filename)
    file_uuid = UUID.uuid4(:hex)
    s3_filename = "#{file_uuid}#{file_extension}"
    s3_bucket = "spotlight.test"
    {:ok, file_binary} = File.read(image_data.path)
    {:ok, a} = ExAws.S3.put_object(s3_bucket, s3_filename, file_binary) |> ExAws.request
    conn
    |> put_status(:ok)
    |> render(Spotlight.MessageDataView, "message_image.json", %{user: user, image: "http://spotlight.test.s3.amazonaws.com/#{s3_filename}"})
  end

  def upload_audio(conn, %{"audio" => audio_data}) do
    user = Guardian.Plug.current_resource(conn)
    file_extension = Path.extname(audio_data.filename)
    file_uuid = UUID.uuid4(:hex)
    s3_filename = "#{file_uuid}#{file_extension}"
    s3_bucket = "spotlight.test"
    {:ok, file_binary} = File.read(audio_data.path)
    {:ok, a} = ExAws.S3.put_object(s3_bucket, s3_filename, file_binary) |> ExAws.request
    conn
    |> put_status(:ok)
    |> render(Spotlight.MessageDataView, "message_audio.json", %{user: user, audio: "http://spotlight.test.s3.amazonaws.com/#{s3_filename}"})
  end
end

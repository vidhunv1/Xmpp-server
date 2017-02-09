defmodule Spotlight.MessageController do
  use Spotlight.Web, :controller
  require Logger

  alias Spotlight.User

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:update]

  def send_message(conn, %{"recipient" => to, "message" => message}) do
  	user = Guardian.Plug.current_resource(conn)

    if(!is_nil(user)) do
      from_username = user.username
      to_username = Repo.get_by(User, [user_id: to]).username
      MessageRouter.send_message(from_username, to_username, Poison.encode!(message))
      send_resp(conn, :ok, "")
    else
      send_resp(conn, 401, "Could not find user.")
    end
  end
end

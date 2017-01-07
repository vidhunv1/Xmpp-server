defmodule Spotlight.MessageController do
  use Spotlight.Web, :controller
  require Logger

  alias Spotlight.User

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:update]

  def send_message(conn, %{"to_id" => to, "message" => message}) do
  	user = Guardian.Plug.current_resource(conn)
  	from_username = user.username
  	to_username = Repo.get_by(User, [user_id: to]).username

    if(!is_nil(user)) do
      MessageRouter.send_message(from_username, to_username, message)
      send_resp(conn, :ok, "")
    else
      send_resp(conn, 401, "Could not find user.")
    end
  end
end

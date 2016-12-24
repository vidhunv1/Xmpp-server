defmodule Spotlight.MessageController do
  use Spotlight.Web, :controller
  require Logger

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:update]

  def send_message(conn, %{"to_id" => to, "message" => message}) do
  	user = Guardian.Plug.current_resource(conn)
  	from = user.username
    MessageRouter.send_message(from, to, message)

    send_resp(conn, :ok, "")
  end
end

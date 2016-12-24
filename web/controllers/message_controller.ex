defmodule Spotlight.MessageController do
  use Spotlight.Web, :controller
  require Logger

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:update]

  def send_message(conn, %{"to_id" => to, "message" => message}) do
  	user = Guardian.Plug.current_resource(conn)
  	from = user.username
  	host = Application.get_env(:spotlight_api, Spotlight.Endpoint)[:url][:host]
    :ejabberd_router.route(
		  {:jid, from, host, "", from, host, ""}, 
		  {:jid, to, host, "", to, host, ""}, 
		  {:xmlel, "message", [{"xml:lang", "en"}, {"to", from<>"@"<>host}, {"type", "chat"}], [{:xmlel, "body", [], [xmlcdata: message]}, {:xmlel, "request", [{"xmlns", "urn:xmpp:receipts"}], []}]}
		  )

    send_resp(conn, :ok, "")
  end
end

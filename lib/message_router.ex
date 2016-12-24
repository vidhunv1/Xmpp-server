defmodule MessageRouter do
  require Logger

  def send_message(from, to, message) do
    host = Application.get_env(:spotlight_api, Spotlight.Endpoint)[:url][:host]
    :ejabberd_router.route(
      {:jid, from, host, "", from, host, ""}, 
      {:jid, to, host, "", to, host, ""}, 
      {:xmlel, "message", [{"xml:lang", "en"}, {"to", from<>"@"<>host}, {"type", "chat"}], [{:xmlel, "body", [], [xmlcdata: message]}, {:xmlel, "request", [{"xmlns", "urn:xmpp:receipts"}], []}]}
      )
  end
end
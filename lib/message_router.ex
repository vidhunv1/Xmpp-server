defmodule MessageRouter do
  require Logger

  def send_message(from, to, message) do
    Logger.info("sending message: "<>from<>", "<>to<>", "<>message)
  	message_uuid = UUID.uuid1()
    host = Application.get_env(:spotlight_api, Spotlight.Endpoint)[:url][:host]
    :ejabberd_router.route(
      {:jid, from, host, "", from, host, ""}, 
      {:jid, to, host, "", to, host, ""}, 
      {:xmlel, "message", [{"xml:lang", "en"}, {"to", from<>"@"<>host}, {"id", message_uuid}, {"type", "chat"}], [{:xmlel, "body", [], [xmlcdata: message]}, {:xmlel, "thread", [], [xmlcdata: message_uuid]}, {:xmlel, "request", [], []} ]}
      )
    {:ok, message_uuid}
  end
end

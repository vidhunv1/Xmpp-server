defmodule ModOfflinePush do
  import Ejabberd.Logger
  @behaviour :gen_mod
  alias Spotlight.Repo
  alias Spotlight.User

  def start(host, _opts) do
    info('Starting ejabberd module mod_offline_push')
    Ejabberd.Hooks.add(:offline_message_hook, host, __ENV__.module, :send_push, 10)
    :ok
  end

  def stop(host) do
    info('Starting ejabberd module mod_offline_push')
    Ejabberd.Hooks.delete(:offline_message_hook, host, __ENV__.module, :send_push, 10)
    :ok
  end

  def send_push(from, to, packet) do
    IO.inspect packet
    #Fix bad match for presence messages
    {:xmlel, "message" , _ , [ {:xmlel,"body",_, [xmlcdata: message] } ,_, _ ]} = packet
    {:jid, jid_to, _host, _, _, _, _} = to
    {:jid, jid_from, _, _, _, _, _} = from

    user = Repo.get_by(User, [username: jid_to])

    info("Offline Push : TO="<>jid_to<>" : FROM ="<>jid_from<>" : Message ="<>message)
    FCM.push([user.notification_token],
        %{notification:
          %{ title: jid_from, body: message, sound: "default"} })
    :ok
  end
end

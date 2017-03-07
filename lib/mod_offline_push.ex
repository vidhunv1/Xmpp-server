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
    {:jid, jid_to, _host, _, _, _, _} = to
    {:jid, jid_from, _, _, _, _, _} = from
    
    IO.inspect packet
    message_group = case packet do
      {:xmlel, "message" , [_, _, {"id", message_id}, {"type", "chat"}], [ {:xmlel,"body",_, [xmlcdata: message] } ,_, _ ]} ->
        {:ok, message, message_id}
      _ ->
        {:error, "", ""}
    end
    IO.inspect message_group

    case message_group do
      {:ok, message, message_id} ->
        user = Repo.get_by(User, [username: jid_to])
        info("Offline Push : TO="<>jid_to<>" : FROM ="<>jid_from<>" : Message ="<>message)
        FCM.push([user.notification_token],
          %{data:
            %{ username: jid_from, message: message, message_id: message_id} })
        :ok
      {:error, _, _} ->
        :ok
    end
  end
end


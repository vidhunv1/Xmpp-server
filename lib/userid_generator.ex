defmodule UseridGenerator do
  require Logger
  alias Spotlight.User
  alias Spotlight.Repo  
  @chars "abcdefghijklmnopqrstuvwxyz1234567890" |> String.split("")
  @default_length 8

  def generate() do
    user_id = Enum.reduce((1..@default_length), [], fn (_i, acc) ->
      [Enum.random(@chars) | acc]
    end) |> Enum.join("")

    get_user = Repo.get_by(User, [user_id: user_id])
    if(is_nil(get_user)) do
    	user_id
    else
    	generate()
    end
  end
end
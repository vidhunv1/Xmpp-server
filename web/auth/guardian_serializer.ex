defmodule Spotlight.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias Spotlight.Repo
  alias Spotlight.User

  def for_token(user = %User{}) do 
  	IO.inspect user
  	{:ok, "User:#{user.username}" }
  end
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("User:" <> username), do: { :ok, Repo.get(User, username) }
  def from_token(_), do: { :error, "Unknown resource type" }
end
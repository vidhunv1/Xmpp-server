defmodule Spotlight.BotView do
  use Spotlight.Web, :view

  def render("show.json", %{user: user, bot_details: bot_details}) do
    %{data: %{
        id: user.id,
        phone: user.phone,
        country_code: user.country_code,
        name: user.name,
        user_id: user.user_id,
        post_url: bot_details.post_url
      }}
  end

  def render("show.json", %{user: user}) do
    {:ok, menu} = 
      if(!is_nil(user.bot_details.persistent_menu)) do
        Poison.decode(user.bot_details.persistent_menu)
      else
        {:ok, nil}
      end
    %{data: %{
        id: user.id,
        name: user.name,
        username: user.username,
        user_id: user.user_id,
        persistent_menu: menu
      }
    }
  end
end

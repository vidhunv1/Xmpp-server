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
    %{data: %{
        id: user.id,
        phone: user.phone,
        country_code: user.country_code,
        name: user.name,
        user_id: user.user_id,
        post_url: user.bot_details.post_url
      }}
  end
end

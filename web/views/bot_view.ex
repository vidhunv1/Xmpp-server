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

  def render("status.json", %{message: message, status: status}) do
    %{status: status,
      message: message}
  end

  def render("discover.json", %{discover_bots: d}) do
    %{status: "success",
      bots: render_many(d, Spotlight.BotView, "bot.json"),
      message: :null}
  end

  def render("bot.json", %{bot: bot}) do
    %{
      category: bot.category,
      cover_picture: bot.cover_picture,
      description: bot.description,
      bot: render_one(bot.user, Spotlight.UserView, "user.json")
    }
  end
end

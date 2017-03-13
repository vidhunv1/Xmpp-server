defmodule Spotlight.UserView do
  use Spotlight.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, Spotlight.UserView, "user.json")}
  end

  def render("show_update.json", %{user: user}) do
      %{status: "success",
        user: render_one(user, Spotlight.UserView, "user_update.json"),
        message: :null}
  end

    def render("show.json", %{user: user}) do
      %{status: "success",
        user: render_one(user, Spotlight.UserView, "user.json"),
        message: :null}
  end

  def render("verified_token.json", %{user: user, access_token: token, exp: exp}) do
      %{status: "success",
        message: "User details updated.",
        user: render_one(user, Spotlight.UserView, "user.json"),
        access_token: token,
        expires: exp
        }
  end

  def render("status.json", %{message: message, status: status}) do
    %{status: status,
      message: message}
  end

  def render("user_update.json", %{user: user}) do
    user_type = case user.username do
      "o_"<>_ -> "official"
      _ -> "regular"
    end
    %{name: user.name,
      phone: user.phone,
      country_code: user.country_code,
      phone_formatted: user.phone_formatted,
      is_registered: user.is_registered,
      profile_dp: SpotlightApi.ImageUploader.url({user.profile_dp, user}),
      username: user.username,
      user_type: user_type,
      user_id: user.user_id}
  end

    def render("user.json", %{user: user}) do
    user_type = case user.username do
      "o_"<>_ -> "official"
      _ -> "regular"
    end
    %{name: user.name,
      is_registered: user.is_registered,
      profile_dp: SpotlightApi.ImageUploader.url({user.profile_dp, user}),
      username: user.username,
      user_type: user_type,
      user_id: user.user_id}
  end

  def render("error.json", %{code: code, message: message}) do
    %{error: %{
      code: code,
      message: message
    }}
  end
end

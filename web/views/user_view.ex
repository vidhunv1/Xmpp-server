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

  def render("create_error.json", %{changeset: changeset}) do
    case List.first(changeset.errors) do
      {key, {error_message, num}} -> 
        render(Spotlight.ErrorView, "error.json", %{title: "Invalid "<>Atom.to_string(key), message: error_message, code: 400})
      {_, _} ->
        render(Spotlight.ErrorView, "error.json", %{title: "Invalid details", message: "Please check the details.", code: 400})
    end
  end

  def render("update_error.json", %{changeset: changeset}) do
    case List.first(changeset.errors) do
      {key, {error_message, num}} -> 
        render(Spotlight.ErrorView, "error.json", %{title: "Invalid "<>Atom.to_string(key), message: error_message, code: 409})
      {_, _} ->
        render(Spotlight.ErrorView, "error.json", %{title: "Invalid details", message: "Please check the details.", code: 409})
    end
  end
end

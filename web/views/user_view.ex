defmodule Spotlight.UserView do
  use Spotlight.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, Spotlight.UserView, "user.json")}
  end

  def render("show.json", %{user: user, message: message, status: status}) do
      %{status: status,
        user: render_one(user, Spotlight.UserView, "user.json"),
        message: message}
  end

  def render("show.json", %{user: user}) do
      %{status: "success",
        user: render_one(user, Spotlight.UserView, "user.json"),
        message: :null}
  end

  def render("verified_token.json", %{user: user, access_token: token, exp: exp}) do
      %{status: "success",
        message: :"Mobile number verified",
        user: render_one(user, Spotlight.UserView, "user.json"),
        access_token: token,
        expiry: exp
        }
  end

  def render("status.json", %{message: message, status: status}) do
    %{status: status,
      message: message}
  end

  def render("user.json", %{user: user}) do
    %{name: user.name,
      phone: user.phone,
      country_code: user.country_code,
      phone_formatted: user.phone_formatted,
      is_registered: user.is_registered,
      username: user.username}
  end

  def render("error.json", %{code: code, message: message}) do
    %{error: %{
      code: code,
      message: message
    }}
  end
end

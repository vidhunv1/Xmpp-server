defmodule Spotlight.UserView do
  use Spotlight.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, Spotlight.UserView, "user.json")}
  end

  def render("show.json", %{user: user, message: message, status: status}) do
      %{status: status,
        data: render_one(user, Spotlight.UserView, "user.json"),
        message: message}
  end

  def render("show.json", %{user: user}) do
      %{status: "success",
        data: render_one(user, Spotlight.UserView, "user.json"),
        message: :null}
  end

  def render("verified_token.json", %{user: user, access_token: token, exp: exp}) do
      %{status: "success",
        data: %{user: render_one(user, Spotlight.UserView, "user.json"),
          access_token: token,
          expiry: exp},
        message: :"Mobile number verified"}
  end

  def render("status.json", %{message: message, status: status}) do
    %{status: status,
      message: message}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name,
      phone: user.phone,
      country_code: user.country_code,
      is_registered: user.is_registered}
  end

  def render("error.json", %{code: code, message: message}) do
    %{error: %{
      code: code,
      message: message
    }}
  end
end

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

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name,
      phone: user.phone,
      country_code: user.country_code,
      verification_status: user.verification_status}
  end

  def render("error.json", %{code: code, message: message}) do
    %{error: %{
      code: code,
      message: message
    }}
  end
end

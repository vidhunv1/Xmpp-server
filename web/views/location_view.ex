defmodule Spotlight.LocationView do
  use Spotlight.Web, :view

  def render("show_nearby.json", %{nearby: nearby}) do
      %{status: "success",
        contacts: render_many(nearby, Spotlight.LocationView, "nearby.json"),
        message: :null}
  end

  def render("nearby.json", %{location: location}) do
    %{
      distance: location.distance,
      latitude: location.latitude,
      longitude: location.longitude,
      user: render_one(location.user, Spotlight.UserView, "user.json")
    }
  end
end

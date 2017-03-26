defmodule Spotlight.AppView do
  use Spotlight.Web, :view

  def render("status.json", %{message: message, status: status}) do
    %{status: status,
      message: message}
  end
end

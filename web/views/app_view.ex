defmodule Spotlight.AppView do
  use Spotlight.Web, :view

  def render("status.json", %{message: message, status: status}) do
    %{status: status,
      message: message}
  end

  def render("app_version.json", %{version_code: version_code, version_name: version_name, is_mandatory: is_mandatory}) do
    %{version_code: version_code,
      version_name: version_name, 
      is_mandatory: is_mandatory}
  end
end

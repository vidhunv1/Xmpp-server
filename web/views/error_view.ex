defmodule Spotlight.ErrorView do
  use Spotlight.Web, :view

  def render("404.json", _assigns) do
    %{errors: %{detail: "Page not found"}}
  end

  def render("400.json", _assigns) do
    %{errors: %{detail: "Bad request"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end

  def render("error.json", %{code: code, message: message, title: title}) do
    %{error: %{
      code: code,
      message: message,
      title: title}
    }
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json", assigns
  end
end

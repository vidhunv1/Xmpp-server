defmodule Spotlight.GuardianErrorHandler do
  use Spotlight.Web, :controller
  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> render(Spotlight.ErrorView, "error.json", %{title: "Error", message: "Invalid Access token", code: 401})
  end
end
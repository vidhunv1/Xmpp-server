defmodule Spotlight.ContactsController do
  use Spotlight.Web, :controller
  require Logger

  alias Spotlight.User
  alias Spotlight.Repo
  alias Spotlight.Contact

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:add]

  def add(conn, %{"user_id" => user_id}) do
    current_user = Guardian.Plug.current_resource(conn)

    case Repo.get_by(User, [user_id: user_id, is_registered: true]) do
      nil -> conn |> put_status(200) |> render(Spotlight.ErrorView, "error.json", %{title: "Not found", message: "Could not find user with the ID.", code: 404})
      contact ->
        Contact.changeset(%Contact{}, %{user_id: current_user.id, contact_id: contact.id}) |> Repo.insert
        if contact.user_type == "official" do
          bot_details = (contact |> Repo.preload(:bot_details)).bot_details
          if(!is_nil(bot_details)) do
            case BotHelper.send_add_hook(contact.user_id, contact.name, contact.phone, contact.bot_details.post_url) do
              {:ok, _} ->
                #Message Delivered
                Logger.info("Delivered ADD_HOOK to #{bot_details.post_url}.")
              {:error, m} ->
                #Error sending message
                Logger.debug("Error APP_HOOK to #{bot_details.post_url}. #{m}")
            end
          end
        end
        conn |> put_status(200) |> render(Spotlight.UserView, "show.json", user: contact)
    end
  end

  def block(conn, %{"user_id" => user_id}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Repo.get_by(User, [user_id: user_id, is_registered: true]) do
      nil -> conn |> put_status(200) |> render(Spotlight.ErrorView, "error.json", %{title: "Not found", message: "Could not find user with the ID.", code: 404})
      contact ->
        Contact.changeset(%Contact{}, %{user_id: current_user.id, contact_id: contact.id, is_blocked: true}) |> Repo.update
        conn |> put_status(200) |> render(Spotlight.UserView, "show.json", user: contact)
    end
  end
end

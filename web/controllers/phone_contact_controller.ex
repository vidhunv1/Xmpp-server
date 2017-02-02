defmodule Spotlight.PhoneContactController do
  use Spotlight.Web, :controller
  require Logger

  alias Spotlight.PhoneContact
  alias Spotlight.User

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:create]

  # def index(conn, _params) do
  #   contacts = Repo.all(Contact)
  #   render(conn, "index.json", contacts: contacts)
  # end

  # def create(conn, %{"phone_contact" => contact_params}) do
  #   IO.inspect(contact_params)
  #   user = Guardian.Plug.current_resource(conn)
  #   contact = Repo.get_by(PhoneContact, [phone: contact_params["phone"], country_code: contact_params["country_code"], user_id: user.id])
  #   contact_user = Repo.get_by(User, [country_code: contact_params["country_code"], phone: contact_params["phone"], is_registered: true])

  #   contact_username = if is_nil(contact_user), do: "", else: contact_user.username
  #   contact_userid = if is_nil(contact_user), do: "", else: contact_user.user_id

  #   if is_nil(contact) do
  #     changeset = user |> Ecto.build_assoc(:phone_contacts) |> PhoneContact.changeset(contact_params)
  #     case Repo.insert(changeset) do
  #       {:ok, contact} ->
  #         conn
  #         |> put_status(:created)
  #         |> render("show.json", %{phone_contact: contact, is_registered: !is_nil(contact_user), username: contact_username, user_id: contact_userid})
  #       {:error, changeset} ->
  #         conn
  #         |> put_status(:unprocessable_entity)
  #         |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
  #     end
  #   else
  #     conn
  #       |> put_status(200)
  #       |> render("show.json", %{phone_contact: contact, is_registered: !is_nil(contact_user), username: contact_username, user_id: contact_userid})
  #   end
  # end

  def create(conn, %{"phone_contacts" => contact_params}) do
    user = Guardian.Plug.current_resource(conn)
    IO.inspect(contact_params)
    contact_list = Poison.decode!(contact_params)
    contacts = Enum.reduce(contact_list, [], fn(contact, acc) ->
      case store_contact(user, contact["country_code"], contact["phone"], contact["name"]) do
        {:ok, contact} ->
          [contact|acc]
        {:error, _} ->
          acc
      end 
    end)
    IO.inspect contacts

    conn
    |> put_status(:created)
    |> render("contacts.json", contacts: contacts)
    # contact = Repo.get_by(PhoneContact, [phone: contact_params["phone"], country_code: contact_params["country_code"], user_id: user.id])
    # contact_user = Repo.get_by(User, [country_code: contact_params["country_code"], phone: contact_params["phone"], is_registered: true])

    # contact_username = if is_nil(contact_user), do: "", else: contact_user.username
    # contact_userid = if is_nil(contact_user), do: "", else: contact_user.user_id

    # if is_nil(contact) do
    #   changeset = user |> Ecto.build_assoc(:phone_contacts) |> PhoneContact.changeset(contact_params)
    #   case Repo.insert(changeset) do
    #     {:ok, contact} ->
    #       conn
    #       |> put_status(:created)
    #       |> render("show.json", %{phone_contact: contact, is_registered: !is_nil(contact_user), username: contact_username, user_id: contact_userid})
    #     {:error, changeset} ->
    #       conn
    #       |> put_status(:unprocessable_entity)
    #       |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
    #   end
    # else
    #   conn
    #     |> put_status(200)
    #     |> render("show.json", %{phone_contact: contact, is_registered: !is_nil(contact_user), username: contact_username, user_id: contact_userid})
    # end
    # conn
    #   |> put_status(:unprocessable_entity)
    #   |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
  end

  defp store_contact(user, contact_country_code, contact_phone, contact_name) do
    contact = Repo.get_by(PhoneContact, [phone: contact_phone, country_code: contact_country_code, name: contact_name, user_id: user.id])
    contact_user = Repo.get_by(User, [country_code: contact_country_code, phone: contact_phone, is_registered: true])

    contact_username = if is_nil(contact_user), do: "", else: contact_user.username
    contact_userid = if is_nil(contact_user), do: "", else: contact_user.user_id

    contact_out = %{phone: contact_phone, country_code: contact_country_code, name: contact_name}
    if is_nil(contact_user) do
      changeset = user |> Ecto.build_assoc(:phone_contacts) |> PhoneContact.changeset(contact_out)
      Logger.info "store_contact #{contact_name}"
      case Repo.insert(changeset) do
        {:ok, contact} ->
          IO.inspect contact
          {:ok, %{phone: contact_phone, country_code: contact_country_code, name: contact_name, is_registered: false, username: contact_username, user_id: contact_userid}}      
        {:error, changeset} ->
          IO.inspect changeset
          {:error, changeset}
      end
    else
      {:ok, %{phone: contact_phone, country_code: contact_country_code, name: contact_name, is_registered: true, username: contact_username, user_id: contact_userid}}      
    end
  end

  # def show(conn, %{"id" => id}) do
    # contact = Repo.get!(Contact, id)
    # render(conn, "show.json", contact: contact)
  # end

  # def update(conn, %{"id" => id, "phone_contact" => contact_params}) do
  #   user = Guardian.Plug.current_resource(conn)
  #   contact = Repo.get_by(PhoneContact, id)
  #   changeset = PhoneContact.changeset(contact, contact_params)

  #   case Repo.update(changeset) do
  #     {:ok, contact} ->
  #       render(conn, "show.json", phone_contact: contact)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   contact = Repo.get!(Contact, id)

  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(contact)

  #   send_resp(conn, :no_content, "")
  # end
end

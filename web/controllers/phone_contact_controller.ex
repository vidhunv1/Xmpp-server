defmodule Spotlight.PhoneContactController do
  use Spotlight.Web, :controller
  require Logger

  alias Spotlight.PhoneContact
  alias Spotlight.User

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:create, :show]

  def create(conn, %{"phone_contacts" => contact_params}) do
    user = Guardian.Plug.current_resource(conn)
    IO.inspect(contact_params)
    contacts = Enum.reduce(contact_params, [], fn(contact, acc) ->
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
  end

   def show(conn, %{"phone_number" => phone}) do
     contact_user = Repo.get_by(User, [phone: phone, is_registered: true])

     conn |> put_status(200) |> render(Spotlight.UserView, "show.json", user: contact_user)
   end

   def show(conn, %{}) do
     user_id = Guardian.Plug.current_resource(conn).id
     contacts = Repo.all(from u in User, inner_join: pc in PhoneContact, on: u.phone == pc.phone, where: pc.user_id == ^user_id and u.is_registered==true)
     conn
     |> put_status(:ok)
     |> render("contacts.json", contacts: contacts)
   end

  defp store_contact(user, contact_country_code, contact_phone, contact_name) do
    contact = Repo.get_by(PhoneContact, [phone: contact_phone, country_code: contact_country_code, name: contact_name, user_id: user.id])
    contact_user = Repo.get_by(User, [phone: contact_phone, is_registered: true])

    contact_username = if is_nil(contact_user), do: "", else: contact_user.username
    contact_userid = if is_nil(contact_user), do: "", else: contact_user.user_id

    contact_out = %{phone: contact_phone, country_code: contact_country_code, name: contact_name}
    if is_nil(contact) do
      changeset = user |> Ecto.build_assoc(:phone_contacts) |> PhoneContact.changeset(contact_out)
      Logger.info "store_contact #{contact_name}"
      case Repo.insert(changeset) do
        {:ok, contact} ->
          IO.inspect contact
          {:ok, %{phone: contact_phone, country_code: contact_country_code, name: contact_name, is_registered: !is_nil(contact_user), username: contact_username, user_id: contact_userid}}
        {:error, changeset} ->
          IO.inspect changeset
          {:error, changeset}
      end
    else
      {:ok, %{phone: contact_phone, country_code: contact_country_code, name: contact_name, is_registered: !is_nil(contact_user), username: contact_username, user_id: contact_userid}}
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

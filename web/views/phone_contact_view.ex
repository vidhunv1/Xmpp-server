defmodule Spotlight.PhoneContactView do
  use Spotlight.Web, :view

  def render("index.json", %{contacts: contacts}) do
    %{data: render_many(contacts, Spotlight.PhoneContactView, "contact.json")}
  end

  def render("show.json", %{phone_contact: contact, is_registered: is_registered, username: username, user_id: user_id}) do
    %{data: %{
        id: contact.id,
        phone: contact.phone,
        country_code: contact.country_code,
        name: contact.name,
        username: username,
        user_id: user_id,
        is_registered: is_registered
      }}
  end

  def render("contacts.json", %{contacts: contacts}) do
    %{data: render_many(contacts, Spotlight.PhoneContactView, "contact.json")}
  end

  def render("contact.json", %{phone_contact: contact}) do
    %{user_id: contact.user_id,
      username: contact.username,
      phone: contact.phone,
      is_registered: contact.is_registered,
      country_code: contact.country_code,
      name: contact.name}
  end
end

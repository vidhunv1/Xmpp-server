defmodule Spotlight.ContactsView do
  use Spotlight.Web, :view

  def render("show.json", %{contacts: contacts}) do
      %{status: "success",
        contacts: render_many(contacts, Spotlight.ContactsView, "user.json"),
        message: :null}
  end

  def render("user.json", %{contacts: contact}) do
    user = contact.contact
    user_type = case user.username do
      "o_"<>_ -> "official"
      _ -> "regular"
    end

   %{name: user.name,
     is_registered: user.is_registered,
     profile_dp: SpotlightApi.ImageUploader.url({user.profile_dp, user}),
     username: user.username,
     user_id: user.user_id,
     user_type: user_type}
 end
end

defmodule Spotlight.PhoneContact do
  use Spotlight.Web, :model

  schema "phone_contacts" do
  	field :phone, :string, size: 20
  	field :country_code, :string, size: 5
  	field :name, :string, size: 100

  	belongs_to :user, Spotlight.User
  end

  @fields ~w(phone country_code name)

  def changeset(model, params \\  %{}) do
    model
    |> cast(params, @fields)
    |> validate_required([:phone, :country_code])
    |> unique_constraint(:unique_user_phone_contact, name: :unique_user_phone_contact)
  end
end
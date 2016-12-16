defmodule Spotlight.PhoneContact do
  use Spotlight.Web, :model

  schema "phone_contacts" do
  	field :phone, :string, size: 20
  	field :country_code, :string, size: 5
  	field :name, :string, size: 100

  	belongs_to :user, Spotlight.User
  end

  @required_fields ~w(phone country_code)
  @optional_fields ~w(name)

  def changeset(model, params \\  %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
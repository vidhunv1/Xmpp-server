defmodule Spotlight.User do
  use Spotlight.Web, :model
  use Arc.Ecto.Schema

  @primary_key {:id, :integer, []}
  schema "users" do
    field :username, :string, size: 30
    field :name, :string, size: 50
    field :phone, :string, size: 20
    field :country_code, :string, size: 5
    field :phone_formatted, :string, size: 25
    field :verification_uuid, :string, size: 50
    field :is_registered, :boolean, default: false
    field :is_cellphone, :boolean, default: false
    field :mobile_carrier, :string, size: 100
    field :notification_token, :string, size: 250
    field :user_id, :string, size: 50
    field :profile_dp, SpotlightApi.ImageUploader.Type

    has_many :phone_contacts, Spotlight.PhoneContact
    has_one :bot_details, Spotlight.Bot
    
    has_many :_contacts, Spotlight.Contact
    has_many :contacts, through: [:_contacts, :contact]
    timestamps default: "2016-01-01 00:00:01"  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @required_fields ~w(phone country_code phone_formatted)
  @optional_fields ~w(verification_uuid is_cellphone mobile_carrier)
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:phone, min: 10)
    |> unique_constraint(:phone)
  end

  @required_fields ~w()
  @optional_fields ~w(name notification_token profile_dp)
  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> cast_attachments(params, [:profile_dp])
  end

  @required_fields ~w(is_registered username user_id)
  @optional_fields ~w()
  def verify_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
  end
end

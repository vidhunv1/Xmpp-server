defmodule Spotlight.User do
  use Spotlight.Web, :model
  use Arc.Ecto.Schema

  @primary_key {:id, :integer, []}
  schema "users" do
    field :username, :string, size: 30
    field :name, :string, size: 50
    field :email, :string, size: 50
    field :user_type, :string, size: 50
    field :phone, :string, size: 20
    field :country_code, :string, size: 5
    field :phone_formatted, :string, size: 25
    field :verification_uuid, :string, size: 50
    field :is_registered, :boolean, default: false
    field :mobile_carrier, :string, size: 100
    field :notification_token, :string, size: 250
    field :user_id, :string, size: 50
    field :imei, :string, size: 50
    field :is_active, :boolean, default: true
    field :is_phone_verified, :boolean, default: false
    field :otp_provider_message, :string, size: 50
    field :profile_dp, SpotlightApi.ImageUploader.Type

    has_many :phone_contacts, Spotlight.PhoneContact
    has_one :bot_details, Spotlight.Bot
    has_one :location, Spotlight.Location
    has_many :message_data, Spotlight.MessageData
    has_many :payment_merchant_hashes, Spotlight.PaymentMerchantHash

    has_many :_contacts, Spotlight.Contact
    has_many :contacts, through: [:_contacts, :contact]
    timestamps default: "2016-01-01 00:00:01"  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @required_fields ~w(phone country_code user_id username)
  @optional_fields ~w(imei mobile_carrier notification_token otp_provider_message verification_uuid email is_registered user_type)
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:phone, min: 10)
  end

  @required_fields ~w()
  @optional_fields ~w(name notification_token profile_dp user_id username is_active)
  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:user_id)
    |> unique_constraint(:username)
    |> cast_attachments(params, [:profile_dp])
  end

  @required_fields ~w(is_registered username user_type)
  @optional_fields ~w()
  def register_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
  end

  @required_fields ~w(verification_uuid)
  @optional_fields ~w(is_phone_verified notification_token)
  def verify_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
  end
end

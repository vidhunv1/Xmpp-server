defmodule Spotlight.User do
  use Spotlight.Web, :model

  schema "users" do
    field :name, :string, size: 50
    field :phone, :string, size: 20
    field :country_code, :string, size: 5
    field :phone_formatted, :string, size: 25
    field :verification_uuid, :string, size: 50
    field :verification_status, :boolean, default: false
    field :is_cellphone, :boolean, default: false
    field :mobile_carrier, :string, size: 100

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @required_fields ~w(phone country_code phone_formatted)
  @optional_fields ~w(verification_uuid is_cellphone mobile_carrier)
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:phone)
  end

  @required_fields ~w()
  @optional_fields ~w(name)
  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
  end

  @required_fields ~w(verification_status)
  @optional_fields ~w()
  def verify_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
  end
end

defmodule Spotlight.User do
  use Spotlight.Web, :model

  schema "users" do
    field :name, :string, size: 50
    field :phone, :string, size: 20
    field :country_code, :string, size: 5
    field :phone_formatted, :string, size: 25
    field :verification_uuid, :string, size: 50
    field :verification_status, :boolean, default: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @required_fields ~w(phone country_code phone_formatted)
  @optional_fields ~w()

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:phone)
  end

  @required_fields ~w()
  @optional_fields ~w(name verification_uuid verification_status)
  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
  end
end

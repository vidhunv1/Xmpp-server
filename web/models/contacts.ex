defmodule Spotlight.Contact do
  use Spotlight.Web, :model

  alias Spotlight.User

  schema "contacts" do
    belongs_to :user, User
    belongs_to :contact, User
    field :is_blocked, :boolean, default: false
    timestamps default: "2016-01-01 00:00:01"
  end

  @required_fields ~w(user_id contact_id)
  @optional_fields ~w(is_blocked)
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
  end
end

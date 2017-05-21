defmodule Spotlight.Location do
	use Spotlight.Web, :model
  alias Spotlight.User

  schema "location" do
  	field :latitude, :float
    field :longitude, :float

  	belongs_to :user, Spotlight.User
    timestamps
  end

  @required_fields ~w(latitude longitude)
  @optional_fields ~w()
  def changeset(model, params \\  %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

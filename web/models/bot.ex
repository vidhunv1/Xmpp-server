defmodule Spotlight.Bot do
	use Spotlight.Web, :model
  alias Spotlight.User
  
  schema "bot_details" do
  	field :post_url, :string, size: 100
    field :persistent_menu, :string, size: 1000

  	belongs_to :user, Spotlight.User
    timestamps
  end

  @required_fields ~w(post_url)
  @optional_fields ~w()
  def changeset(model, params \\  %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  @required_fields ~w(persistent_menu)
  @optional_fields ~w()
  def menu_changeset(model, params \\  %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
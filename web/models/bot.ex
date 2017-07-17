defmodule Spotlight.Bot do
	use Spotlight.Web, :model
  alias Spotlight.User

  schema "bot_details" do
  	field :post_url, :string, size: 100
    field :persistent_menu, :string, size: 1000
		field :should_app_init_hook, :boolean, default: false
		field :category, :string, size: 100
    field :cover_picture, :string, size: 100
    field :description, :string, size: 250

  	belongs_to :user, Spotlight.User
    timestamps
  end

  @required_fields ~w(post_url)
  @optional_fields ~w(persistent_menu should_app_init_hook category cover_picture description)
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

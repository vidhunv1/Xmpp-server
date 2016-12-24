defmodule Spotlight.Bot do
	use Spotlight.Web, :model
  alias Spotlight.User
  
  schema "bot_details" do
  	field :post_url, :string, size: 100

  	belongs_to :user, Spotlight.User
    timestamps
  end

  @required_fields ~w(post_url)
  @optional_fields ~w()

  def changeset(model, params \\  %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
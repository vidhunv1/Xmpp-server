defmodule Spotlight.MessageData do
	use Spotlight.Web, :model
  alias Spotlight.User
	use Arc.Ecto.Schema

  schema "message_data" do
  	field :data,  SpotlightApi.ImageUploader.Type
  	field :data_type, :string, size: 20

  	belongs_to :user, Spotlight.User
    timestamps
  end

  @required_fields ~w(data data_type)
  @optional_fields ~w()
  def create_data(model, params \\  %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
		|> cast_attachments(params, [:data_url])
  end
end

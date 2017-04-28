defmodule Spotlight.PaymentsDetails do
	use Spotlight.Web, :model

  schema "payments_details" do
  	field :transaction_id, :string, size: 100
    field :amount, :float, size: 100
		field :product_info, :string, size: 200
    field :email, :string, size: 50, default: ""
    field :first_name, :string, size: 50
    field :phone, :string, size: 15
    field :status, :string, size: 10
    field :mihpayid, :string, size: 100
    field :payment_id, :string, size: 100
    field :error_message, :string, size: 100
		field :user_id, :string, size: 100
		field :created_by_user_id, :string, size: 100
		field :transaction_secret, :string, size: 200
		field :is_delivered, :boolean, default: false

    timestamps
  end

  @required_fields ~w(transaction_id amount product_info first_name phone user_id created_by_user_id transaction_secret)
  @optional_fields ~w(email)
  def create_transaction(model, params \\  %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

	@required_fields ~w(status mihpayid payment_id error_message is_delivered)
	@optional_fields ~w()
	def update_transaction(model, params \\  %{}) do
		model
		|> cast(params, @required_fields, @optional_fields)
	end
end

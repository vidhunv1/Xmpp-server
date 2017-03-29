defmodule Spotlight.PaymentsDetails do
	use Spotlight.Web, :model

  schema "payments_details" do
  	field :transaction_id, :string, size: 100
    field :amount, :float, size: 100
		field :product_info, :string, size: 200
    field :email, :string, size: 50
    field :first_name, :string, size: 50
    field :phone, :string, size: 15
    field :status, :string, size: 10
    field :mihpayid, :string, size: 100
    field :payment_id, :string, size: 100
    field :error_message, :string, size: 100
		field :user_id, :string, size: 100

    timestamps
  end

  @required_fields ~w(transaction_id amount product_info email first_name phone user_id)
  @optional_fields ~w()
  def create_transaction(model, params \\  %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

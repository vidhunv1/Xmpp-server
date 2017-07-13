defmodule Spotlight.PaymentMerchantHash do
  use Spotlight.Web, :model

  schema "payment_merchant_hashes" do
    field :merchant_key, :string
    field :user_credentials, :string
    field :card_token, :string
    field :merchant_hash, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:merchant_key, :user_credentials, :card_token, :merchant_hash])
    |> validate_required([:merchant_key, :user_credentials, :card_token, :merchant_hash])
  end
end

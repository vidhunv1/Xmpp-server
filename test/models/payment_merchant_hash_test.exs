defmodule Spotlight.PaymentMerchantHashTest do
  use Spotlight.ModelCase

  alias Spotlight.PaymentMerchantHash

  @valid_attrs %{card_token: "some content", merchant_hash: "some content", merchant_key: "some content", user_credentials: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PaymentMerchantHash.changeset(%PaymentMerchantHash{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PaymentMerchantHash.changeset(%PaymentMerchantHash{}, @invalid_attrs)
    refute changeset.valid?
  end
end

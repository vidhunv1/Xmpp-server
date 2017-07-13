defmodule Spotlight.Repo.Migrations.CreatePaymentMerchantHash do
  use Ecto.Migration

  def change do
    create table(:payment_merchant_hashes) do
      add :merchant_key, :text
      add :user_credentials, :text
      add :card_token, :text
      add :merchant_hash, :text

      timestamps()
    end

  end
end

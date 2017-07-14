defmodule Spotlight.Repo.Migrations.AddFieldsToPaymentMerchantHashes do
  use Ecto.Migration

  def change do
    alter table(:payment_merchant_hashes) do
      add :card_number_masked, :string
      add :card_type, :string
    end
  end
end

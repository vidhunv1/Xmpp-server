defmodule Spotlight.Repo.Migrations.AddUseridToPaymentMerchantHashes do
  use Ecto.Migration

  def change do
    alter table(:payment_merchant_hashes) do
      add :user_id, references(:users)
    end
  end
end

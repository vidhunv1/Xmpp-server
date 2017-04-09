defmodule Spotlight.Repo.Migrations.AddTransactionSecretToPaymentDetails do
  use Ecto.Migration

  def change do
    alter table(:payments_details) do
      add :transaction_secret, :string
    end
  end
end

defmodule Spotlight.Repo.Migrations.AddTransactionSecretToPaymentDetails do
  use Ecto.Migration

  def change do
    add :transaction_secret, :string
  end
end

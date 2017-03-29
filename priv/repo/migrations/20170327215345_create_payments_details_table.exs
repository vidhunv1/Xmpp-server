defmodule Spotlight.Repo.Migrations.CreatePaymentsDetailsTable do
  use Ecto.Migration

  def change do
    create table(:payments_details) do
      add :transaction_id, :string
      add :amount, :float
      add :product_info, :string
      add :email, :string
      add :first_name, :string
      add :phone, :string
      add :status, :string
      add :mihpayid, :string
      add :payment_id, :string
      add :error_message, :string
      add :user_id, :string

      timestamps default: "2016-01-01 00:00:01"
    end
    create unique_index(:payments_details, [:transaction_id])
  end
end

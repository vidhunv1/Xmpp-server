defmodule Spotlight.Repo.Migrations.AddIsDeliveredToPaymentDetails do
  use Ecto.Migration

  def change do
    alter table(:payments_details) do
      add :is_delivered, :boolean, default: false, null: false
    end
  end
end

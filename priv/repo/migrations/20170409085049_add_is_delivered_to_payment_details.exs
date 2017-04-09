defmodule Spotlight.Repo.Migrations.AddIsDeliveredToPaymentDetails do
  use Ecto.Migration

  def change do
    add :is_delivered, :boolean, default: false, null: false
  end
end

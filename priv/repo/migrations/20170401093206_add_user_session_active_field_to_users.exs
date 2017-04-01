defmodule Spotlight.Repo.Migrations.AddUserSessionActiveFieldToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_active, :boolean, default: true, null: false
      add :imei, :string, default: "", null: false
    end
  end
end

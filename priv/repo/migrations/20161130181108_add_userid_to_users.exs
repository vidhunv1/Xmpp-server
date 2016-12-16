defmodule Spotlight.Repo.Migrations.AddUseridToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :user_id, :string
    end
    create index(:users, [:user_id])
  end
end

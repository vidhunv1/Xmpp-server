defmodule Spotlight.Repo.Migrations.AddIsBlockedToContacts do
  use Ecto.Migration

  def change do
    alter table(:contacts) do
      add :is_blocked, :boolean, default: false, null: false
    end
  end
end

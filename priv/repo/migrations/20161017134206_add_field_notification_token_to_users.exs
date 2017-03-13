defmodule Spotlight.Repo.Migrations.AddFieldNotificationTokenToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :notification_token, :string
    end
  end
end

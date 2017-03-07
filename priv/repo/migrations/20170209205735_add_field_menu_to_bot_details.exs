defmodule Spotlight.Repo.Migrations.AddFieldMenuToBotDetails do
  use Ecto.Migration

  def change do
    alter table(:bot_details) do
      add :persistent_menu, :string, size: 1000
    end
  end
end

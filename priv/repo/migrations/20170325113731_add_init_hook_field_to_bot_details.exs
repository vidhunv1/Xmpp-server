defmodule Spotlight.Repo.Migrations.AddInitHookFieldToBotDetails do
  use Ecto.Migration

  def change do
    alter table(:bot_details) do
      add :should_app_init_hook, :boolean, default: false, null: false
    end
  end
end

defmodule Spotlight.Repo.Migrations.AddStarsToBotDetails do
  use Ecto.Migration

  def change do
    alter table(:bot_details) do
      add :stars, :int, default: 0
    end
  end
end

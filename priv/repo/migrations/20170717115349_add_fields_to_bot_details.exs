defmodule Spotlight.Repo.Migrations.AddFieldsToBotDetails do
  use Ecto.Migration

  def change do
    alter table(:bot_details) do
      add :cover_picture, :string, default: ""
    end
  end
end

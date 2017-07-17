defmodule Spotlight.Repo.Migrations.AddDescriptionToBotDetails do
  use Ecto.Migration

  def change do
    alter table(:bot_details) do
      add :description, :string, default: ""
    end
  end
end

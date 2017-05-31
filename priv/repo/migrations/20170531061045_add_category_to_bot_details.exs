defmodule Spotlight.Repo.Migrations.AddCategoryToBotDetails do
  use Ecto.Migration

  def change do
    alter table(:bot_details) do
      add :category, :string, size: 100
    end
  end
end

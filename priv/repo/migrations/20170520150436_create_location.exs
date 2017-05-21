defmodule Spotlight.Repo.Migrations.CreateLocation do
  use Ecto.Migration

  def change do
    create table(:location) do
      add :latitude, :float
      add :longitude, :float
      add :user_id, references(:users)
      timestamps default: "2016-01-01 00:00:01"
    end
  end
end

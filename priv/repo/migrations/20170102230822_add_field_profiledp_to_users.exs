defmodule Spotlight.Repo.Migrations.AddFieldProfiledpToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :profile_dp, :string
    end
  end
end

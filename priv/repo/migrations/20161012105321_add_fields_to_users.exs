defmodule Spotlight.Repo.Migrations.AddFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :mobile_carrier, :string
      add :is_cellphone, :boolean
    end

  end
end

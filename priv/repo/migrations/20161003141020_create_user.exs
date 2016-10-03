defmodule Spotlight.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :phone, :string
      add :country_code, :string
      add :phone_formatted, :string
      add :verification_uuid, :string
      add :verification_status, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:users, [:phone])
    create index(:users, [:phone_formatted])
  end
end

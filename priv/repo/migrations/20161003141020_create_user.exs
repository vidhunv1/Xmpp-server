defmodule Spotlight.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, primary_key: true
    #  add :password, :string, null: false
    #  add :serverkey, :string, default: "", null: false
    #  add :salt, :string, default: "", null: false
    #  add :iterationcount, :integer, default: 0, null: false
      add :name, :string
      add :phone, :string
      add :country_code, :string
      add :phone_formatted, :string
      add :verification_uuid, :string
      add :verification_status, :boolean, default: false, null: false

      timestamps default: "2016-01-01 00:00:01"
    end

    create unique_index(:users, [:phone])
    create index(:users, [:phone_formatted])
  end
end

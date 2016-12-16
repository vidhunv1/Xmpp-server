defmodule Spotlight.Repo.Migrations.AddUserPhoneContactsTable do
  use Ecto.Migration

  def change do
    create table(:phone_contacts) do
      add :phone, :string, size: 30
      add :name, :string, size: 100
      add :country_code, :string, size: 5
      add :user_id, references(:users)
    end
    create unique_index(:phone_contacts, [:phone, :country_code, :user_id], name: "unique_user_phone_contact")
  end
end

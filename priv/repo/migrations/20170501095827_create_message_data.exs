defmodule Spotlight.Repo.Migrations.CreateMessageData do
  use Ecto.Migration

  def change do
    create table(:message_data) do
    	add :data, :string, size: 100
      add :data_type, :string, size: 20
    	add :user_id, references(:users)
      timestamps()
    end
  end
end

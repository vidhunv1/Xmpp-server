defmodule Spotlight.Repo.Migrations.CreateBotDetailsTable do
  use Ecto.Migration

  def change do
    create table(:bot_details) do
    	add :post_url, :string, size: 100
    	add :user_id, references(:users)
      timestamps()
    end
  	create unique_index(:bot_details, [:user_id])
  end
end

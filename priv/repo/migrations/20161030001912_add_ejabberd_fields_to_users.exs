defmodule Spotlight.Repo.Migrations.AddEjabberdFieldsToUsers do
  use Ecto.Migration

  def change do
  	alter table(:users) do
    	add :password, :string
    	add :serverkey, :string, default: "", null: false
    	add :salt, :string, default: "", null: false
    	add :iterationcount, :integer, default: 0, null: false
    end	
  end
end

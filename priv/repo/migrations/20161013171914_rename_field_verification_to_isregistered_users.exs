defmodule Spotlight.Repo.Migrations.RenameFieldVerificationToIsregisteredUsers do
  use Ecto.Migration

  def change do
    rename table(:users), :verification_status, to: :is_registered
  end
end

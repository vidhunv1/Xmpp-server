defmodule Spotlight.Repo.Migrations.AddPhoneVerificationPrimaryToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_phone_verified, :boolean, default: false, null: false
      add :otp_provider_message, :string
    end

    drop unique_index(:users, [:email])
  end
end

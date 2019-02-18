defmodule BankAccounting.Repo.Migrations.CreateBalanceMovements do
  use Ecto.Migration

  def change do
    create table(:balance_movements) do
      add :user_id, references(:users, on_delete: :nothing)
      add :source_account_id, references(:accounts, on_delete: :nothing)
      add :destination_account_id, references(:accounts, on_delete: :nothing)
      add :amount, :decimal

      timestamps()
    end

    create index(:balance_movements, [:user_id])
    create index(:balance_movements, [:source_account_id])
    create index(:balance_movements, [:destination_account_id])
  end
end

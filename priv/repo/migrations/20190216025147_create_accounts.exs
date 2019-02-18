defmodule BankAccounting.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :balance, :decimal

      timestamps()
    end

    create constraint(:accounts, :balance_must_be_positive,
             check: "balance >= 0.0",
             comment: "O saldo da conta deve ser maior ou igual que zero"
           )
  end
end

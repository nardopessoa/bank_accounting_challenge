defmodule BankAccounting.Bank.Account do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankAccounting.Bank.BalanceMovement

  schema "accounts" do
    has_many :debit_movements, BalanceMovement, foreign_key: :source_account_id
    has_many :credit_movements, BalanceMovement, foreign_key: :destination_account_id

    field :balance, :decimal

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:balance])
    |> validate_required([:balance])
  end
end

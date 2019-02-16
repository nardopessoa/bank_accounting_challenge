defmodule BankAccounting.Bank.BalanceMovement do
  use Ecto.Schema
  import Ecto.Changeset

  @allowed ~w(user_id source_account_id destination_account_id amount)a

  schema "balance_movements" do
    belongs_to :user, BankAccounting.Auth.User
    belongs_to :source_account, BankAccounting.Bank.Account
    belongs_to :destination_account, BankAccounting.Bank.Account

    field :amount, :decimal

    timestamps()
  end

  @doc false
  def changeset(balance_movement, attrs) do
    balance_movement
    |> cast(attrs, @allowed)
    |> validate_required(@allowed)
  end
end

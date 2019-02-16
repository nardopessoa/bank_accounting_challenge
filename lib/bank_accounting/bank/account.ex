defmodule BankAccounting.Bank.Account do
  use Ecto.Schema
  import Ecto.Changeset


  schema "accounts" do
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

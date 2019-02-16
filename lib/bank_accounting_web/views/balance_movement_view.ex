defmodule BankAccountingWeb.BalanceMovementView do
  use BankAccountingWeb, :view
  alias BankAccountingWeb.BalanceMovementView

  def render("show.json", %{balance_movement: balance_movement}) do
    %{data: render_one(balance_movement, BalanceMovementView, "balance_movement.json")}
  end

  def render("balance_movement.json", %{balance_movement: balance_movement}) do
    %{id: balance_movement.id, amount: balance_movement.amount}
  end
end

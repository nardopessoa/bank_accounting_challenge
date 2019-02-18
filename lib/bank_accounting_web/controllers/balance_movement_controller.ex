defmodule BankAccountingWeb.BalanceMovementController do
  use BankAccountingWeb, :controller

  alias BankAccounting.Bank
  alias BankAccounting.Bank.BalanceMovement
  alias BankAccounting.Guardian

  action_fallback BankAccountingWeb.FallbackController

  def create(conn, %{"balance_movement" => balance_movement_params}) do
    user = Guardian.Plug.current_resource(conn)
    balance_movement_params = Map.put(balance_movement_params, "user_id", user.id)

    with {:ok, %BalanceMovement{} = balance_movement} <-
           Bank.create_balance_movement(balance_movement_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.balance_movement_path(conn, :show, balance_movement))
      |> render("show.json", balance_movement: balance_movement)
    end
  end

  def show(conn, %{"id" => id}) do
    balance_movement = Bank.get_balance_movement!(id)
    render(conn, "show.json", balance_movement: balance_movement)
  end

  def delete(conn, %{"id" => id}) do
    balance_movement = Bank.get_balance_movement!(id)

    with {:ok, %BalanceMovement{}} <- Bank.delete_balance_movement(balance_movement) do
      send_resp(conn, :no_content, "")
    end
  end
end

defmodule BankAccountingWeb.AccountController do
  use BankAccountingWeb, :controller

  alias BankAccounting.Bank
  alias BankAccounting.Bank.Account

  action_fallback BankAccountingWeb.FallbackController

  def index(conn, _params) do
    accounts = Bank.list_accounts()
    render(conn, "index.json", accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Bank.create_account(account_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.account_path(conn, :show, account))
      |> render("show.json", account: account)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Bank.get_account!(id)
    render(conn, "show.json", account: account)
  rescue
    Ecto.NoResultsError ->
      conn
      |> put_status(:not_found)
      |> render("not_found.json", id: id)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Bank.get_account!(id)

    with {:ok, %Account{} = account} <- Bank.update_account(account, account_params) do
      render(conn, "show.json", account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Bank.get_account!(id)

    with {:ok, %Account{}} <- Bank.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end
end

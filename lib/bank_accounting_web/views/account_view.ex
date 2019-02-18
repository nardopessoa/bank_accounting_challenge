defmodule BankAccountingWeb.AccountView do
  use BankAccountingWeb, :view
  alias BankAccountingWeb.AccountView

  def render("index.json", %{accounts: accounts}) do
    %{data: render_many(accounts, AccountView, "account.json")}
  end

  def render("show.json", %{account: account}) do
    %{data: render_one(account, AccountView, "account.json")}
  end

  def render("account.json", %{account: account}) do
    %{id: account.id, balance: account.balance}
  end

  def render("not_found.json", %{id: _id}) do
    %{error: "A conta informada não existe"}
  end
end

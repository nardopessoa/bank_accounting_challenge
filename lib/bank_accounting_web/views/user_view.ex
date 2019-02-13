defmodule BankAccountingWeb.UserView do
  use BankAccountingWeb, :view
  alias BankAccountingWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, username: user.username}
  end

  def render("access_token.json", %{access_token: token}) do
    %{access_token: token}
  end
end

defmodule BankAccountingWeb.UserView do
  use BankAccountingWeb, :view

  def render("show.json", %{user: user}) do
    %{data: render_one(user, __MODULE__, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, username: user.username}
  end

  def render("access_token.json", %{access_token: token}) do
    %{access_token: token}
  end
end

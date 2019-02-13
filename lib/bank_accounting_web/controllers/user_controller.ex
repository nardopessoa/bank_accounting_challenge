defmodule BankAccountingWeb.UserController do
  use BankAccountingWeb, :controller

  alias BankAccounting.Auth
  alias BankAccounting.Auth.User
  alias BankAccounting.Guardian

  action_fallback BankAccountingWeb.FallbackController

  def index(conn, _params) do
    users = Auth.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Auth.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render("access_token.json", access_token: token)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Auth.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Auth.get_user!(id)

    with {:ok, %User{} = user} <- Auth.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Auth.get_user!(id)

    with {:ok, %User{}} <- Auth.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def login(conn, %{"username" => username, "password" => password}) do
    case Auth.token_sign_in(username, password) do
      {:ok, token, _claims} -> render(conn, "access_token.json", access_token: token)
      error -> error
    end
  end
end

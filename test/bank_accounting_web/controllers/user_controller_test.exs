defmodule BankAccountingWeb.UserControllerTest do
  use BankAccountingWeb.ConnCase
  import BankAccounting.Guardian
  alias BankAccounting.Auth

  @password "some password_encrypted"
  @create_attrs %{
    password: @password,
    password_confirmation: @password,
    username: "some username"
  }
  @invalid_attrs %{password_encrypted: nil, username: nil}

  def fixture(:user) do
    {:ok, user} = Auth.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders access_token when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"access_token" => token} = json_response(conn, 201)
    end

    test "renders user when data is valid", %{conn: conn} do
      {:ok, user: user} = create_user(:user)
      {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{token}")
        |> get(Routes.user_path(conn, :show))

      user_id = user.id

      assert %{"id" => ^user_id, "username" => "some username"} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end

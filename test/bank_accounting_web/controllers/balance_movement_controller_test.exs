defmodule BankAccountingWeb.BalanceMovementControllerTest do
  use BankAccountingWeb.ConnCase

  alias BankAccounting.Bank

  @valid_attrs %{amount: "120.5"}
  @invalid_attrs %{amount: nil}

  def fixture(_identifier, attrs \\ %{})

  def fixture(:account, attrs) do
    {:ok, account} =
      attrs
      |> Enum.into(%{balance: "10000.00"})
      |> Bank.create_account()

    account
  end

  def fixture(:balance_movement, attrs) do
    {:ok, balance_movement} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Bank.create_balance_movement()

    balance_movement
  end

  setup %{conn: conn} do
    {user, token} = create_and_sign_in_user()

    source_account = fixture(:account)
    destination_account = fixture(:account)

    attrs = %{
      user_id: user.id,
      source_account_id: source_account.id,
      destination_account_id: destination_account.id
    }

    conn =
      conn
      |> put_req_header("authorization", "bearer #{token}")
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn, attrs: attrs}
  end

  describe "create balance_movement" do
    test "renders balance_movement when data is valid", %{conn: conn, attrs: attrs} do
      attrs = Enum.into(attrs, @valid_attrs)
      conn = post(conn, Routes.balance_movement_path(conn, :create), balance_movement: attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.balance_movement_path(conn, :show, id))

      assert %{"id" => id, "amount" => "120.5"} = json_response(conn, 200)["data"]
    end

    test "renders errors when amount is invalid", %{conn: conn, attrs: attrs} do
      attrs = Enum.into(attrs, @invalid_attrs)
      conn = post(conn, Routes.balance_movement_path(conn, :create), balance_movement: attrs)

      assert %{"amount" => ["Campo obrigatório"]} = json_response(conn, 422)["errors"]
    end

    test "renders errors when source_account is invalid", %{conn: conn, attrs: attrs} do
      attrs =
        attrs
        |> Map.update!(:source_account_id, &(&1 + 999_999_999))
        |> Enum.into(@valid_attrs)

      conn = post(conn, Routes.balance_movement_path(conn, :create), balance_movement: attrs)

      assert %{"source_account_id" => ["Conta origem não existe!"]} =
               json_response(conn, 422)["errors"]
    end

    test "renders errors when destination_account is invalid", %{conn: conn, attrs: attrs} do
      attrs =
        attrs
        |> Map.update!(:destination_account_id, &(&1 + 999_999_999))
        |> Enum.into(@valid_attrs)

      conn = post(conn, Routes.balance_movement_path(conn, :create), balance_movement: attrs)

      assert %{"destination_account_id" => ["Conta destino não existe!"]} =
               json_response(conn, 422)["errors"]
    end

    test "renders errors when amount is greather than account balance", %{
      conn: conn,
      attrs: attrs
    } do
      attrs =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.update!(:amount, &(&1 |> Decimal.new() |> Decimal.add(999_999_999) |> to_string()))

      conn = post(conn, Routes.balance_movement_path(conn, :create), balance_movement: attrs)

      assert %{"source_account_id" => ["A conta de origem não possui saldo suficiente."]} =
               json_response(conn, 422)["errors"]
    end
  end

  describe "delete balance_movement" do
    setup [:create_balance_movement]

    test "deletes chosen balance_movement", %{conn: conn, balance_movement: balance_movement} do
      conn = delete(conn, Routes.balance_movement_path(conn, :delete, balance_movement))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.balance_movement_path(conn, :show, balance_movement))
      end
    end
  end

  defp create_balance_movement(%{attrs: attrs}) do
    balance_movement = fixture(:balance_movement, attrs)
    {:ok, balance_movement: balance_movement}
  end
end

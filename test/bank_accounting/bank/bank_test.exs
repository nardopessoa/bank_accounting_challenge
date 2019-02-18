defmodule BankAccounting.BankTest do
  use BankAccounting.DataCase

  alias BankAccounting.Auth
  alias BankAccounting.Bank

  describe "accounts" do
    alias BankAccounting.Bank.Account

    @valid_attrs %{balance: "9120.5"}
    @update_attrs %{balance: "7456.7"}
    @invalid_attrs %{balance: nil}

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Bank.create_account()

      account
    end

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Bank.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Bank.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      assert {:ok, %Account{} = account} = Bank.create_account(@valid_attrs)
      assert account.balance == Decimal.new("9120.5")
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bank.create_account(@invalid_attrs)
    end

    test "create_account/1 with balance less than zero returns error changeset" do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               @valid_attrs
               |> Map.update!(:balance, &(&1 |> Decimal.new() |> Decimal.mult(-1) |> to_string()))
               |> Bank.create_account()

      assert [
               balance: {_, [validation: :number, kind: :greater_than_or_equal_to, number: 0.0]}
             ] = errors
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      assert {:ok, %Account{} = account} = Bank.update_account(account, @update_attrs)
      assert account.balance == Decimal.new("7456.7")
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Bank.update_account(account, @invalid_attrs)
      assert account == Bank.get_account!(account.id)
    end

    test "update_account/2 with balance less than zero returns error changeset" do
      account = account_fixture()

      update_attrs =
        @update_attrs
        |> Map.update!(:balance, &(&1 |> Decimal.new() |> Decimal.mult(-1) |> to_string()))

      assert {:error, %Ecto.Changeset{errors: errors}} =
               Bank.update_account(account, update_attrs)

      assert [
               balance: {_, [validation: :number, kind: :greater_than_or_equal_to, number: 0.0]}
             ] = errors

      assert account == Bank.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Bank.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Bank.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Bank.change_account(account)
    end
  end

  describe "balance_movement" do
    alias BankAccounting.Bank.BalanceMovement

    @valid_attrs %{amount: 120.5}
    @invalid_attrs %{amount: nil}

    def balance_movement_fixture(attrs \\ %{}) do
      {:ok, balance_movement} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Bank.create_balance_movement()

      balance_movement
    end

    setup do
      user_attrs = %{
        password: "1234567890",
        password_confirmation: "1234567890",
        username: "username"
      }

      {:ok, user} = Auth.create_user(user_attrs)

      source_account = account_fixture()
      destination_account = account_fixture()

      attrs = %{
        user_id: user.id,
        source_account_id: source_account.id,
        destination_account_id: destination_account.id
      }

      {:ok, attrs: attrs}
    end

    test "get_balance_movement!/1 returns the balance_movement with given id", %{attrs: attrs} do
      balance_movement = balance_movement_fixture(attrs)
      assert Bank.get_balance_movement!(balance_movement.id) == balance_movement
    end

    test "create_balance_movement/1 with valid data creates a balance_movement", %{attrs: attrs} do
      assert {:ok, %BalanceMovement{} = balance_movement} =
               attrs
               |> Enum.into(@valid_attrs)
               |> Bank.create_balance_movement()

      assert balance_movement.amount == Decimal.new("120.5")
    end

    test "create_balance_movement/1 with invalid amount returns error changeset", %{attrs: attrs} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               attrs
               |> Enum.into(@invalid_attrs)
               |> Bank.create_balance_movement()

      assert [amount: {_, [validation: :required]}] = errors
    end

    test "create_balance_movement/1 with invalid source_account returns error changeset",
         %{attrs: attrs} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               attrs
               |> Map.update!(:source_account_id, &(&1 + 999_999_999))
               |> Enum.into(@valid_attrs)
               |> Bank.create_balance_movement()

      assert [source_account_id: {_, [constraint: :foreign, constraint_name: _]}] = errors
    end

    test "create_balance_movement/1 with invalid destination_account returns error changeset",
         %{attrs: attrs} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               attrs
               |> Map.update!(:destination_account_id, &(&1 + 999_999_999))
               |> Enum.into(@valid_attrs)
               |> Bank.create_balance_movement()

      assert [destination_account_id: {_, [constraint: :foreign, constraint_name: _]}] = errors
    end

    test "create_balance_movement/1 with amount greather than balance returns error changeset",
         %{attrs: attrs} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               attrs
               |> Enum.into(@valid_attrs)
               |> Map.update!(:amount, &(&1 + 999_999_999))
               |> Bank.create_balance_movement()

      assert [source_account_id: {_, [constraint: :check_violation, constraint_name: _]}] = errors
    end

    test "delete_balance_movement/1 deletes the balance_movement", %{attrs: attrs} do
      balance_movement = balance_movement_fixture(attrs)
      assert {:ok, %BalanceMovement{}} = Bank.delete_balance_movement(balance_movement)
      assert_raise Ecto.NoResultsError, fn -> Bank.get_balance_movement!(balance_movement.id) end
    end
  end
end

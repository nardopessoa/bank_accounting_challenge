defmodule BankAccounting.BankTest do
  use BankAccounting.DataCase

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
end

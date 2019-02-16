defmodule BankAccounting.AuthTest do
  use BankAccounting.DataCase

  alias BankAccounting.Auth

  describe "users" do
    alias BankAccounting.Auth.User

    @password "some password_encrypted"
    @valid_attrs %{
      password: @password,
      password_confirmation: @password,
      username: "some username"
    }
    @update_attrs %{
      password: @password <> "_updated",
      password_confirmation: @password <> "_updated",
      username: "some updated username"
    }
    @invalid_attrs %{password: nil, password_confirmation: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_user()

      user
    end

    def user_fixture_clean_password(attrs \\ %{}) do
      # por serem colunas virtuais, após consultar a base e dados, elas não são preenchidas
      Map.merge(user_fixture(attrs), %{password: nil, password_confirmation: nil})
    end

    test "list_users/0 returns all users" do
      user = user_fixture_clean_password()
      assert Auth.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture_clean_password()
      assert Auth.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Auth.create_user(@valid_attrs)
      assert Bcrypt.verify_pass("some password_encrypted", user.password_encrypted)
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Auth.update_user(user, @update_attrs)
      assert Bcrypt.verify_pass("some password_encrypted_updated", user.password_encrypted)
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture_clean_password()
      assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, @invalid_attrs)
      assert user == Auth.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Auth.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Auth.change_user(user)
    end
  end
end

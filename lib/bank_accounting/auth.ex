defmodule BankAccounting.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias BankAccounting.Repo
  alias BankAccounting.Guardian
  alias BankAccounting.Auth.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def token_sign_in(username, password) do
    with {:ok, user} <- get_by_username(username),
         {:ok, user} <- verify_password(password, user) do
      Guardian.encode_and_sign(user)
    else
      {:error, error} -> {:error, error}
      _ -> {:error, :unauthorized}
    end
  end

  defp get_by_username(username) when is_binary(username) do
    User
    |> Repo.get_by(username: username)
    |> verify_user()
  end

  defp verify_user(nil), do: Bcrypt.no_user_verify()
  defp verify_user(user), do: {:ok, user}

  defp verify_password(password, %User{} = user) when is_binary(password) do
    password
    |> Bcrypt.verify_pass(user.password_encrypted)
    |> if(do: {:ok, user}, else: {:error, :invalid_password})
  end
end

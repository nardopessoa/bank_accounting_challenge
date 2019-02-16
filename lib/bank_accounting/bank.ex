defmodule BankAccounting.Bank do
  @moduledoc """
  The Bank context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias BankAccounting.Repo

  alias BankAccounting.Bank.Account

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{source: %Account{}}

  """
  def change_account(%Account{} = account) do
    Account.changeset(account, %{})
  end

  alias BankAccounting.Bank.BalanceMovement

  @doc """
  Gets a single balance_movement.

  Raises `Ecto.NoResultsError` if the BalanceMovement does not exist.

  ## Examples

      iex> get_balance_movement!(123)
      %BalanceMovement{}

      iex> get_balance_movement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_balance_movement!(id), do: Repo.get!(BalanceMovement, id)

  @doc """
  Creates a balance_movement.

  ## Examples

      iex> create_balance_movement(%{field: value})
      {:ok, %BalanceMovement{}}

      iex> create_balance_movement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_balance_movement(attrs \\ %{}) do
    balance_movement_changeset = BalanceMovement.changeset(%BalanceMovement{}, attrs)

    if not balance_movement_changeset.valid? do
      {:error, balance_movement_changeset}
    else
      %{
        "source_account_id" => source_account_id,
        "destination_account_id" => destination_account_id,
        "amount" => amount
      } = attrs

      result =
        Multi.new()
        |> Multi.insert(:balance_movement, balance_movement_changeset)
        |> Multi.update_all(
          :source_account,
          from(account in Account, where: account.id == ^source_account_id),
          inc: [balance: amount * -1]
        )
        |> Multi.update_all(
          :destination_account,
          from(account in Account, where: account.id == ^destination_account_id),
          inc: [balance: amount]
        )
        |> Repo.transaction()

      {:ok, result} = result
      {:ok, result[:balance_movement]}
    end
  end

  @doc """
  Deletes a BalanceMovement.

  ## Examples

      iex> delete_balance_movement(balance_movement)
      {:ok, %BalanceMovement{}}

      iex> delete_balance_movement(balance_movement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_balance_movement(%BalanceMovement{} = balance_movement) do
    Repo.delete(balance_movement)
  end
end

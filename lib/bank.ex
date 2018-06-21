defmodule Bank do

  use GenServer

  require Logger

  alias Bank.BankActions
  alias Bank.BankActions.{CreateAction, WithdrawAction, DepositAction, BalanceAction,  GetBalancesAction}


  @spec create(String.t) :: :ok
  def create(name), do: notify(%CreateAction{name: name})

  @spec deposit(String.t, float()) :: :ok
  def deposit(name, amount), do: notify(%DepositAction{name: name, amount: amount})

  @spec withdraw(String.t, float()) :: :ok
  def withdraw(name, amount), do: notify(%WithdrawAction{name: name, amount: amount})

  @spec balance(atom(), String.t) :: {:ok, float()}
  def balance(bank, name), do: GenServer.call(bank, %BalanceAction{name: name})


  def start_link(name), do: GenServer.start_link(__MODULE__, name, name: name)

  def start(name) do
    GenServer.start(__MODULE__, name, name: name)
  end


  @spec init(atom()) :: {:ok, map()}
  def init(name) do
    {:ok, balance} = initial_balances(name)
    subscribe(name)
    {:ok, balance}
  end

  @spec initial_balances(atom()) :: {:ok, map()}
  defp initial_balances(my_name) do
    case :gproc.lookup_pids({:p, :l, :banks}) do
        [first | _] -> GenServer.call(first, %GetBalancesAction{})
        _ -> {:ok, %{}}
    end
  end

  @spec subscribe(atom()) :: true
  defp subscribe(name) do
      Logger.info("Subscribing with name #{inspect name}")
      :gproc.reg({:p, :l, :banks})
  end

  defp notify(action), do: :gproc.send({:p, :l, :banks}, action)


  @spec handle_info(action :: BankActions.alter, state :: map()) :: {:noreply, map()}

  def handle_info(%CreateAction{name: name}, balances) do
    new_state = if Map.has_key?(balances, name) do
        balances
    else
        Map.put(balances, name, 0)
    end
    {:noreply, new_state}
  end

  def handle_info(%DepositAction{name: name, amount: amount}, balances) do
    old_balance = Map.get(balances, name)
    new_state = if old_balance do
        Map.put(balances, name, old_balance + amount)
    else
        balances
    end
    {:noreply, new_state}
  end


  def handle_info(%WithdrawAction{name: name, amount: amount}, balances) do
    old_balance = Map.get(balances, name)
    new_state = if old_balance do
        Map.put(balances, name, old_balance - amount)
    else
        balances
    end
    {:noreply, new_state}
  end


  @spec handle_call(BankActions.info, any, map()) :: {:reply, {:ok, float() | map()}, map()}

  def handle_call(%BalanceAction{name: name}, _from, balances) do
    balance = Map.get(balances, name)
    reply = if balance do
        {:ok, balance}
    else
        {:error, :not_found}
    end
    {:reply, reply, balances}
  end

  def handle_call(%GetBalancesAction{}, _from, balances) do
      {:reply, {:ok, balances}, balances}
  end
end

defmodule BankTest do
  use ExUnit.Case
  doctest Bank

  test "greets the world" do
    Bank.start(:bank1)
    Bank.start(:bank2)
    Bank.start(:bank3)
    Bank.start(:bank4)

    Bank.create("Simon Schulz")

    spawn fn ->
          for _ <- 1..1000, do: spawn fn -> Bank.deposit("Simon Schulz", 10) end 
    end

    spawn fn ->
        for _ <- 1..100, do: spawn fn -> Bank.withdraw("Simon Schulz", 10) end 
    end

    Process.sleep(1000)

    assert {:ok, 9000} == Bank.balance(:bank1, "Simon Schulz")
    assert {:ok, 9000} == Bank.balance(:bank2, "Simon Schulz")
    assert {:ok, 9000} == Bank.balance(:bank3, "Simon Schulz")
    assert {:ok, 9000} == Bank.balance(:bank4, "Simon Schulz")

    Bank.start(:bank5)
    assert {:ok, 9000} == Bank.balance(:bank5, "Simon Schulz")
  end
end

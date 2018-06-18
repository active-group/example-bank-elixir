defmodule Bank.BankActions do

    defmodule CreateAction do
        @enforce_keys [:name]
        defstruct [:name]
        @type t :: %CreateAction{name: String.t}
    end 

    defmodule BalanceAction do
        @enforce_keys [:name]
        defstruct [:name]
        @type t :: %BalanceAction{name: String.t}
    end 
    
    defmodule WithdrawAction do 
        @enforce_keys [:name, :amount]
        defstruct [:name, :amount]
        @type t :: %WithdrawAction{name: String.t, amount: float}
    end

    defmodule DepositAction do 
        @enforce_keys [:name, :amount]
        defstruct [:name, :amount]
        @type t :: %DepositAction{name: String.t, amount: float}
    end
    
    defmodule GetBalancesAction do
        defstruct []
        @type t :: %GetBalancesAction{}
    end


    @type alter :: CreateAction.t() | WithdrawAction.t() | DepositAction.t() 
    @type info :: BalanceAction.t() | GetBalancesAction.t()


end

defmodule Campinas.Effects.StateTest do
  use ExUnit.Case

  import Campinas.Effects.State, only: [run_state: 2]

  test "program1" do
    assert run_state(StateCases.program1(11), 20) == {:ok, 63, 31}
    assert run_state(StateCases.program1(0), 20) == {:ok, 41, 20}
    assert run_state(StateCases.program1(11), -1) == {:ok, 21, 10}
  end

  test "program2" do
    assert run_state(StateCases.program2(11), 20) == {:ok, 63, 124}
    assert run_state(StateCases.program2(10), 20) == {:ok, 61, 41}
  end
end

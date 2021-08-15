defmodule Campinas.Effects.ErrorTest do
  use ExUnit.Case

  import Campinas.Effects.Error, only: [run_error: 2]

  test "program1" do
    handler = fn
      {:too_big, n} ->
        send(self(), {:big_number, n})

        if rem(n, 2) == 0 do
          {:cont, 0}
        else
          :halt
        end

      e ->
        send(self(), {:some_error, e})
        :halt
    end

    assert run_error(ErrorCases.program1(2), handler) == {:ok, 0}
    refute_receive {:big_number, _}
    refute_receive {:some_error, _}

    assert run_error(ErrorCases.program1(11), handler) == {:ok, -1}
    assert_receive {:big_number, 120}
    refute_receive {:some_error, _}

    assert run_error(ErrorCases.program1(0), handler) == {:error, :negative}
    refute_receive {:big_number, _}
    assert_receive {:some_error, :negative}
  end
end

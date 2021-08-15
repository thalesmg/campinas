defmodule StateCases do
  use Campinas
  alias Campinas.Effects.State

  defcps program1(x) do
    s1 = @[State.get()]
    s2 = x + s1
    @[State.set(s2)]
    2 * s2 + 1
  end

  defcps program2(x) do
    s1 = @[State.get()]
    s2 = x + s1

    if rem(s2, 2) == 0 do
      @[State.set(s2 + 11)]
    else
      @[State.set(4 * s2)]
    end

    2 * s2 + 1
  end
end

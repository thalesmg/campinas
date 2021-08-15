defmodule ErrorCases do
  use Campinas
  alias Campinas.Effects.Error

  defcps program1(x) do
    y = x * x - 1

    if y < 0 do
      @[Error.error(:negative)]
    end

    result =
      if y > 100 do
        @[Error.error({:too_big, y})]
      else
        div(y, 2)
      end

    result - 1
  end
end

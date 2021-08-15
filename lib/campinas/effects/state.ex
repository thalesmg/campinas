defmodule Campinas.Effects.State do
  use Campinas

  defcps get() do
    shift out do
      {__MODULE__, :get, out}
    end
  end

  defcps set(s) do
    shift out do
      {__MODULE__, :set, s, out}
    end
  end

  defmacro run_state(prog, state) do
    prog =
      Campinas.transform(
        quote do
          reset do
            @[unquote(prog)]
          end
        end,
        __CALLER__.module
      )

    quote do
      Campinas.Effects.State.__go__(unquote(prog), unquote(state))
    end
  end

  def __go__(prog, state) do
    prog.(fn
      {__MODULE__, :get, out} when is_function(out, 1) ->
        __go__(out.(state), state)

      {__MODULE__, :set, new_state, out} when is_function(out, 1) ->
        __go__(out.(:ok), new_state)

      result ->
        {:ok, result, state}
    end)
  end
end

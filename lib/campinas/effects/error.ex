defmodule Campinas.Effects.Error do
  use Campinas

  defcps error(e) do
    shift out do
      {__MODULE__, :error, e, out}
    end
  end

  defmacro run_error(prog, handler) do
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
      Campinas.Effects.Error.__go__(unquote(prog), unquote(handler))
    end
  end

  def __go__(prog, handler) do
    prog.(fn
      {__MODULE__, :error, e, out} when is_function(out, 1) ->
        case handler.(e) do
          {:cont, v} ->
            __go__(out.(v), handler)

          :halt ->
            {:error, e}
        end

      result ->
        {:ok, result}
    end)
  end
end

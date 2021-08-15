defmodule Campinas do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(
        __MODULE__,
        :__cps_functions__,
        accumulate: true
      )

      @before_compile Campinas
      import Campinas, only: [defcps: 2]
    end
  end

  defmacro __before_compile__(env) do
    cps_fns =
      env.module
      |> Module.get_attribute(:__cps_functions__)
      |> Enum.sort_by(&elem(&1, 0))

    quote do
      def __cps_functions__(), do: unquote(cps_fns)
      Module.delete_attribute(__MODULE__, :__cps_functions__)
    end
  end

  defmacro defcps(clause, do: body) do
    {fn_name, _, args} = clause
    arity = length(args)

    quote do
      Module.put_attribute(
        __MODULE__,
        :__cps_functions__,
        {unquote(fn_name), unquote(arity)}
      )

      def unquote(clause) do
        unquote(transform(body, __CALLER__.module))
      end
    end
  end

  defmacro runCPS(expr) do
    quote do
      unquote(expr).(&Function.identity/1)
    end
  end

  def transform(ast, env \\ __MODULE__)

  def transform({:reset, _meta, [[do: body]]}, env) do
    k = unique_var(:k, env)

    quote do
      fn unquote(k) ->
        unquote(k).(unquote(transform(body, env)).(&Function.identity/1))
      end
    end
  end

  def transform({:shift, _meta, [_bind = {name, _, nil}, [do: body]]}, env) do
    k_outer = unique_var(:k_outer, env)
    k_ = unique_var(:k_, env)
    a = unique_var(:a, env)
    f = Macro.var(name, env)

    cont =
      quote do
        unquote(f) = fn unquote(a) ->
          fn unquote(k_) ->
            unquote(k_).(unquote(k_outer).(unquote(a)))
          end
        end
      end

    cpsed =
      body
      |> annotate_shift_uses(name)
      |> transform(env)

    quote do
      fn unquote(k_outer) ->
        unquote(cont)
        unquote(cpsed).(&Function.identity/1)
      end
    end
  end

  # raw expression; used to compose CPS expressions
  def transform({:@, _meta, [[expr]]}, _env) do
    expr
  end

  # shift continuation use
  def transform({{:shift_use, name}, _meta, [arg]}, env) do
    # if we consider cont as a value before passing it as the cpsed
    # function, everything works out... why?!
    name
    |> Macro.var(env)
    |> transform_value(env)
    |> transform_application(arg, env)
  end

  # shift continuation (not applied)
  def transform({{:shift_use, name}, _meta, nil}, env) do
    name
    |> Macro.var(env)
    |> transform_value(env)
  end

  # shift use (field access)
  def transform(
        {{:., _meta1, [shift_usage = {{:shift_use, _cont_name}, _meta2, [_arg]}, field]}, _meta3,
         []},
        env
      ) do
    transform(
      quote do
        Map.fetch!(unquote(shift_usage), unquote(field))
      end,
      env
    )
  end

  # map literal
  def transform({:%{}, _meta, args}, env) when is_list(args) do
    transform(quote(do: Map.new([unquote_splicing(args)])), env)
  end

  # struct literal
  def transform({:%, _meta, [struct_module, args]}, env) do
    transform(quote(do: Kernel.struct(unquote(struct_module), unquote(args))), env)
  end

  # tuple literal
  def transform({:{}, _meta, args}, env) when is_list(args) do
    transform(quote(do: List.to_tuple([unquote_splicing(args)])), env)
  end

  # alias
  def transform(ast = {:__aliases__, _meta, args}, env) when is_list(args) do
    transform_value(ast, env)
  end

  # assign
  def transform({:=, _meta, [_pat, expr]}, env) do
    transform(expr, env)
  end

  # block
  def transform({:__block__, _meta, [fst | rest]}, env) do
    rest_cpsed =
      case rest do
        [snd] ->
          transform(snd, env)

        rest ->
          transform(quote(do: (unquote_splicing(rest))), env)
      end

    pats = get_patterns(fst)

    k = unique_var(:k, env)
    n = unique_var(:n, env)

    quote do
      fn unquote(k) ->
        unquote(transform(fst, env)).(fn unquote(n) ->
          unquote(prepend_patterns(pats, n))
          unquote(rest_cpsed).(unquote(k))
        end)
      end
    end
  end

  # if
  def transform({:if, _meta, [condition, branches]}, env) do
    true_branch = Keyword.fetch!(branches, :do)
    false_branch = Keyword.get(branches, :else, nil)

    k = unique_var(:k, env)
    b = unique_var(:b, env)

    quote do
      fn unquote(k) ->
        unquote(transform(condition, env)).(fn unquote(b) ->
          if unquote(b) do
            unquote(transform(true_branch, env)).(unquote(k))
          else
            unquote(transform(false_branch, env)).(unquote(k))
          end
        end)
      end
    end
  end

  # direct lambda application
  def transform(
        {
          {:., _meta1, [{:fn, _meta2, [{:->, _meta3, [vars, body]}]}]},
          _meta4,
          args
        },
        env
      )
      when is_list(args) do
    if args == [] do
      k = unique_var(:k, env)
      m = unique_var(:m, env)

      quote do
        fn unquote(k) ->
          unquote(transform_lambda(vars, body, env)).(fn unquote(m) ->
            unquote(m).().(unquote(k))
          end)
        end
      end
    else
      cpsed_lam = transform_lambda(vars, body, env)

      Enum.reduce(args, cpsed_lam, fn v, cpsed ->
        transform_application(cpsed, v, env)
      end)
    end
  end

  # lambda / abstraction
  def transform({:fn, _meta1, [{:->, _meta2, [vars, body]}]}, env) do
    vars
    |> transform_lambda(body, env)
    # lambda itself is a value
    |> transform_value(env)
  end

  # named lambda application
  def transform({{:., _meta1, [f]}, _meta3, args}, env) do
    # assume var is already curried and cpsed, not a primitive
    if args == [] do
      k = unique_var(:k, env)
      m = unique_var(:m, env)

      quote do
        fn unquote(k) ->
          unquote(f).(fn unquote(m) ->
            unquote(m).().(unquote(k))
          end)
        end
      end
    else
      Enum.reduce(args, f, fn arg, acc ->
        transform_application(acc, arg, env)
      end)
    end
  end

  # fn application / primitive application
  def transform({prim, _meta, args}, env)
      when is_list(args) and (is_atom(prim) or is_tuple(prim)) do
    # primitive fns return "pure" values and do not receive
    # continuations as args
    k = unique_var(:k, env)
    vars = Enum.map(args, fn _ -> unique_var(:a, env) end)
    app0 = quote(do: unquote(k).(unquote(prim)(unquote_splicing(vars))))

    body =
      args
      |> Stream.zip(vars)
      |> Enum.reduce(app0, fn {arg, var}, acc ->
        quote do
          unquote(transform(arg, env)).(fn unquote(var) ->
            unquote(acc)
          end)
        end
      end)

    quote do
      fn unquote(k) ->
        unquote(body)
      end
    end
  end

  # 2-tuple
  def transform({a, b}, env) do
    transform(quote(do: List.to_tuple([unquote(a), unquote(b)])), env)
  end

  # list literal
  def transform([x | rest], env) do
    transform(
      quote do
        Campinas.cons(unquote(x), unquote(rest))
      end,
      env
    )
  end

  # any other value
  def transform(v, env) do
    transform_value(v, env)
  end

  def show!(quoted) do
    quoted
    |> Macro.to_string()
    |> Code.format_string!()
    |> Enum.join("")
  end

  def print!(quoted) do
    quoted
    |> show!()
    |> IO.puts()
  end

  def cons(x, rest) do
    [x | rest]
  end

  defp unique_var(name, env) do
    {name, meta, ctx} = Macro.unique_var(name, env)

    ctr =
      case Keyword.fetch!(meta, :counter) do
        {_, ctr} -> ctr
        ctr -> abs(ctr)
      end

    {:"#{name}#{ctr}", meta, ctx}
  end

  defp get_patterns({:=, _meta, [pat, expr]}) do
    [pat | get_patterns(expr)]
  end

  defp get_patterns(_ast) do
    [quote(do: _)]
  end

  defp prepend_patterns(pats, expr) do
    pats
    |> Enum.reverse()
    |> Enum.reduce(expr, fn pat, acc ->
      quote(do: unquote(pat) = unquote(acc))
    end)
  end

  defp transform_value(v, env) do
    k = unique_var(:k, env)

    quote do
      fn unquote(k) ->
        unquote(k).(unquote(v))
      end
    end
  end

  def transform_lambda(
        vars,
        body,
        env
      ) do
    if vars == [] do
      k = unique_var(:k, env)

      quote do
        fn unquote(k) ->
          unquote(k).(fn ->
            unquote(transform(body, env))
          end)
        end
      end
    else
      k = unique_var(:k, env)

      body0 =
        quote do
          fn unquote(k) ->
            unquote(transform(body, env)).(unquote(k))
          end
        end

      vars
      |> Enum.reverse()
      |> Enum.reduce(
        body0,
        fn var, acc ->
          k = unique_var(:k, env)

          quote do
            fn unquote(k) ->
              unquote(k).(fn unquote(var) ->
                unquote(acc)
              end)
            end
          end
        end
      )
    end
  end

  defp transform_application(cps_fn, v, env) do
    k = unique_var(:k, env)
    m = unique_var(:m, env)
    n = unique_var(:n, env)

    quote do
      fn unquote(k) ->
        unquote(cps_fn).(fn unquote(m) ->
          unquote(transform(v, env)).(fn unquote(n) ->
            unquote(m).(unquote(n)).(unquote(k))
          end)
        end)
      end
    end
  end

  defp annotate_shift_uses(
         ast = {:shift, _meta, [_bind = {cont_name, _, nil}, [do: _body]]},
         cont_name
       ) do
    # same name: stop recursing
    ast
  end

  defp annotate_shift_uses({:shift, meta, [bind = {_other_name, _, nil}, [do: body]]}, cont_name) do
    # other name: continue
    if is_list(body) do
      {:shift, meta, [bind, [do: Enum.map(body, &annotate_shift_uses(&1, cont_name))]]}
    else
      {:shift, meta, [bind, [do: annotate_shift_uses(body, cont_name)]]}
    end
  end

  defp annotate_shift_uses({cont_name, meta, [arg]}, cont_name) do
    # usage
    {{:shift_use, cont_name}, meta, [annotate_shift_uses(arg, cont_name)]}
  end

  defp annotate_shift_uses({cont_name, meta, nil}, cont_name) do
    # pure cont
    {{:shift_use, cont_name}, meta, nil}
  end

  defp annotate_shift_uses(
         {{:., meta1, [{cont_name, meta2, [arg]}, field]}, meta3, []},
         cont_name
       ) do
    # field access
    {{:., meta1,
      [{{:shift_use, cont_name}, meta2, [annotate_shift_uses(arg, cont_name)]}, field]}, meta3,
     []}
  end

  defp annotate_shift_uses({f, meta, args}, cont_name)
       when is_list(args) and (is_atom(f) or is_tuple(f)) do
    # fn call
    {f, meta, Enum.map(args, &annotate_shift_uses(&1, cont_name))}
  end

  defp annotate_shift_uses(ast, _cont_name) do
    # something else
    ast
  end
end

defmodule TestCases do
  use Campinas

  def local_fn0() do
    :res
  end

  def local_fn1(x) do
    x - 1
  end

  def local_fn2(x, y) do
    div(x, y)
  end

  defcps trivial0() do
    4
  end

  defcps trivial01() do
    4 + 3
  end

  defcps trivial02() do
    4 + OtherModule.plus1(3)
  end

  defcps trivial03() do
    reset do
      4
    end
  end

  defcps trivial04() do
    3 +
      reset do
        4
      end
  end

  defcps trivial05() do
    shift out do
      4 + 2
    end
  end

  defcps trivial06() do
    shift out do
      4 + out(2)
    end
  end

  defcps trivial1() do
    reset do
      shift cont do
        4
      end
    end
  end

  defcps trivial12() do
    1 +
      reset do
        2 +
          shift cont do
            4
          end
      end
  end

  defcps trivial2() do
    reset do
      shift cont do
        cont(4)
      end
    end
  end

  defcps trivial22() do
    reset do
      2 +
        shift cont do
          cont(4)
        end
    end
  end

  defcps trivial3() do
    reset do
      shift cont do
        cont(cont(4))
      end
    end
  end

  defcps trivial4() do
    reset do
      shift cont do
        3 + cont(4)
      end
    end
  end

  defcps shift_reset1() do
    1 +
      reset do
        2 *
          shift c do
            3 + c(4)
          end
      end
  end

  defcps shift_reset2() do
    1 +
      reset do
        2 *
          shift c do
            3 + 4
          end
      end
  end

  defcps shift_reset3() do
    1 +
      reset do
        2 *
          shift c do
            3 + c(c(4))
          end
      end
  end

  defcps shift_reset4() do
    1 +
      reset do
        1 +
          2 *
            shift cont do
              3 + cont(2) - cont(0)
            end
      end
  end

  defcps local() do
    2 +
      reset do
        5 * @[TestCases.trivial06()]
      end
  end

  # http://okmij.org/ftp/continuations/cc-monad.ml
  # (* The Standard shift test
  #  (display (+ 10 (reset (+ 2 (shift k (+ 100 (k (k 3))))))))
  #  ; --> 117
  # *)
  defcps oleg() do
    10 +
      reset do
        2 +
          shift k do
            100 + k(k(3))
          end
      end
  end

  defcps map1() do
    %{
      "a" => 1 + 2,
      "b" => 3 + 4
    }
  end

  defcps tuple2a() do
    {1, 2}
  end

  defcps tuple2b() do
    {1, 2 + 3}
  end

  defcps tuple3() do
    {1 + 2, 3 * 4, 5 - 6}
  end

  defcps block1() do
    1 + 2
    3 + 4
  end

  defcps block2() do
    1 + 2
    3 + 4
    6 - 7
  end

  defcps assign1() do
    x = 1 + 2
  end

  defcps assign2() do
    x = 1 + 2
    y = x + 3
    y
  end

  defcps assign3() do
    x =
      1 +
        shift cont do
          2 * cont(9)
        end

    x + 13
  end

  defcps assign4() do
    1 +
      reset do
        x =
          1 +
            shift cont do
              2 * cont(9)
            end

        x + 13
      end
  end

  defcps assign5() do
    _ = 1 + 2
  end

  defcps assign6() do
    _ = 1 + 2
    10
  end

  defcps assign7() do
    _x = y = 1 + 2
    y
  end

  defcps assign8a() do
    x = 3
    ^x = y = 1 + 2
    y
  end

  defcps assign8b() do
    x = 3
    y = ^x = 1 + 2
    y
  end

  defcps assign_map1() do
    %{a: x} = %{a: 1 + 2}
    x
  end

  defcps assign_tuple1() do
    {x, y, z} = {1 + 2, 3 - 4, 5 * 6}
    {z, y, x}
  end

  defcps tuple2c() do
    {1,
     2 +
       shift cont do
         elem(cont(2), 1)
       end}
  end

  defcps tuple2d() do
    {1, 2,
     3 +
       shift cont do
         elem(cont(4), 2)
       end}
  end

  defcps list1() do
    [
      1,
      shift cont do
        tl(cont(4))
      end
    ]
  end

  defcps list2() do
    [1, 2, 3]
  end

  defcps list3() do
    []
  end

  defcps list4() do
    [x, y | rest] = [1, 2, 3, 4]

    rest ++ [y, x]
  end

  defcps tuple4() do
    {shift cont do
       1
     end, 2}
  end

  defcps assign9() do
    x = 10 + 2

    z =
      1 +
        reset do
          y =
            7 +
              shift cont do
                2 * cont(9 + x)
              end

          y + 13
        end

    z + 100
  end

  defcps struct1() do
    %Struto{x: 10, y: 20}
  end

  defcps struct2() do
    %Struto{x: x} = %Struto{x: 10, y: 20}
    x
  end

  defcps struct3() do
    reset do
      %Struto{x: x, y: y} = %Struto{
        x: 10,
        y:
          shift cont do
            cont(20)
          end
      }

      x + y
    end
  end

  defcps return_cont() do
    reset do
      1 +
        2 *
          shift cont do
            cont
          end
    end
  end

  defcps multiple_cont_uses() do
    1 +
      reset do
        2 +
          shift cont do
            cont(3) + cont(4)
          end
      end
  end

  defcps field_access() do
    m = %{a: 10, b: 20}
    m.a
  end

  defcps field_access_cont1() do
    %{
      a:
        shift cont do
          cont(20).a
        end
    }
  end

  defcps field_access_cont2() do
    %{
      a:
        shift cont do
          cont(20).a + cont(30).b
        end,
      b: 32
    }
  end

  defcps field_access_cont3() do
    reset do
      %{
        a:
          shift cont do
            cont(22)
          end,
        b:
          shift cont do
            cont(33)
          end
      }
    end
  end

  defcps multiple_shifts1() do
    reset do
      1 +
        shift cont do
          2 * cont(3)
        end +
        shift cont do
          -1 * cont(4)
        end
    end
  end

  defcps multiple_shifts2() do
    reset do
      1 +
        shift cont do
          -1 * cont(4)
        end +
        shift cont do
          2 * cont(3)
        end
    end
  end

  defcps nested_shifts_same_name1() do
    reset do
      1 +
        shift cont do
          2 *
            shift cont do
              cont(3)
            end
        end
    end
  end

  defcps nested_shifts_same_name2() do
    reset do
      1 +
        shift cont do
          -1 *
            cont(
              2 *
                shift cont do
                  cont(3)
                end
            )
        end
    end
  end

  defcps nested_shifts_other_name1a() do
    reset do
      1 +
        shift cont1 do
          -1 *
            cont1(
              2 *
                shift cont2 do
                  cont1(3)
                end
            )
        end
    end
  end

  defcps nested_shifts_other_name1b() do
    reset do
      1 +
        shift cont1 do
          -1 *
            cont1(
              2 *
                shift cont2 do
                  cont2(3)
                end
            )
        end
    end
  end

  defcps conditional1(x) do
    if x > 0 do
      1
    else
      -1
    end
  end

  defcps conditional2(x) do
    if x >= 0 do
      :non_negative
    else
      :negative
    end
  end

  defcps conditional3(x) do
    if x >= 0 do
      :non_negative
    end
  end

  defcps conditional4() do
    if @[OtherModule.flip()] do
      send(self(), :true_branch)
      1
    else
      send(self(), :false_branch)
      2
    end
  end

  defcps conditional5(x) do
    if x >= 0 do
      if x >= 20 do
        :very_big
      else
        :medium
      end
    else
      if -10 <= x do
        :small
      else
        :very_small
      end
    end
  end

  defcps triples(n, s) do
    x = @[OtherModule.choice(n)]
    y = @[OtherModule.choice(x - 1)]
    z = @[OtherModule.choice(y - 1)]

    if x + y + z == s do
      send(self(), {:found, {x, y, z}})
    else
      @[OtherModule.fail()]
    end
  end

  defcps ret_lambda1() do
    fn -> :res end
  end

  defcps ret_lambda2() do
    fn x -> x * 99 end
  end

  defcps ret_lambda3() do
    fn x, y -> x - y end
  end

  defcps ret_lambda_compose1() do
    f = @[TestCases.ret_lambda1()]
    f.()
  end

  defcps ret_lambda_compose2() do
    f = @[TestCases.ret_lambda2()]
    f.(11)
  end

  defcps ret_lambda_compose3() do
    f = @[TestCases.ret_lambda3()]
    f.(9, 11)
  end

  defcps app_lambda_directly1() do
    (fn -> :res end).()
  end

  defcps app_lambda_directly2() do
    (fn x -> x * 99 end).(11)
  end

  defcps app_lambda_directly3() do
    (fn x, y -> x - y end).(20, 10)
  end

  defcps block_with_lambda1() do
    f = fn -> :res end
    f.()
  end

  defcps block_with_lambda2() do
    f = fn x -> x + 1 end
    f.(10)
  end

  defcps block_with_lambda3() do
    f = fn x, y -> x - y end
    f.(10, 13)
  end

  defcps local_fn_call0() do
    local_fn0()
  end

  defcps local_fn_call1() do
    local_fn1(3)
  end

  defcps local_fn_call2() do
    local_fn2(10, 2)
  end
end

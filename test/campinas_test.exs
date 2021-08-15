defmodule CampinasTest do
  use ExUnit.Case

  import Campinas, only: [runCPS: 1]

  test "trivial0" do
    assert runCPS(TestCases.trivial0()) == 4
  end

  test "trivial01" do
    assert runCPS(TestCases.trivial01()) == 7
  end

  test "trivial02" do
    assert runCPS(TestCases.trivial02()) == 8
  end

  test "trivial03" do
    assert runCPS(TestCases.trivial03()) == 4
  end

  test "trivial04" do
    assert runCPS(TestCases.trivial04()) == 7
  end

  test "trivial05" do
    assert runCPS(TestCases.trivial05()) == 6
  end

  test "trivial06" do
    assert runCPS(TestCases.trivial06()) == 6
  end

  test "trivial1" do
    assert runCPS(TestCases.trivial1()) == 4
  end

  test "trivial12" do
    assert runCPS(TestCases.trivial12()) == 5
  end

  test "trivial2" do
    assert runCPS(TestCases.trivial2()) == 4
  end

  test "trivial22" do
    assert runCPS(TestCases.trivial22()) == 6
  end

  test "trivial3" do
    assert runCPS(TestCases.trivial3()) == 4
  end

  test "trivial4" do
    assert runCPS(TestCases.trivial4()) == 7
  end

  test "shift_reset1" do
    assert runCPS(TestCases.shift_reset1()) == 12
  end

  test "shift_reset2" do
    assert runCPS(TestCases.shift_reset2()) == 8
  end

  test "shift_reset3" do
    assert runCPS(TestCases.shift_reset3()) == 20
  end

  test "shift_reset4" do
    assert runCPS(TestCases.shift_reset4()) == 8
  end

  test "local" do
    assert runCPS(TestCases.local()) == 16
  end

  test "oleg" do
    assert runCPS(TestCases.oleg()) == 117
  end

  test "map1" do
    assert runCPS(TestCases.map1()) == %{"a" => 3, "b" => 7}
  end

  test "tuple2a" do
    assert runCPS(TestCases.tuple2a()) == {1, 2}
  end

  test "tuple2b" do
    assert runCPS(TestCases.tuple2b()) == {1, 5}
  end

  test "tuple2c" do
    assert runCPS(TestCases.tuple2c()) == 4
  end

  test "tuple2d" do
    assert runCPS(TestCases.tuple2d()) == 7
  end

  test "tuple3" do
    assert runCPS(TestCases.tuple3()) == {3, 12, -1}
  end

  test "block1" do
    assert runCPS(TestCases.block1()) == 7
  end

  test "block2" do
    assert runCPS(TestCases.block2()) == -1
  end

  test "assign1" do
    assert runCPS(TestCases.assign1()) == 3
  end

  test "assign2" do
    assert runCPS(TestCases.assign2()) == 6
  end

  test "assign3" do
    assert runCPS(TestCases.assign3()) == 46
  end

  test "assign4" do
    assert runCPS(TestCases.assign4()) == 47
  end

  test "assign5" do
    assert runCPS(TestCases.assign5()) == 3
  end

  test "assign6" do
    assert runCPS(TestCases.assign6()) == 10
  end

  test "assign7" do
    assert runCPS(TestCases.assign7()) == 3
  end

  test "assign8a" do
    assert runCPS(TestCases.assign8a()) == 3
  end

  test "assign8b" do
    assert runCPS(TestCases.assign8b()) == 3
  end

  test "assign_map1" do
    assert runCPS(TestCases.assign_map1()) == 3
  end

  test "assign_tuple1" do
    assert runCPS(TestCases.assign_tuple1()) == {30, -1, 3}
  end

  test "list1" do
    assert runCPS(TestCases.list1()) == [4]
  end

  test "list2" do
    assert runCPS(TestCases.list2()) == [1, 2, 3]
  end

  test "list3" do
    assert runCPS(TestCases.list3()) == []
  end

  test "list4" do
    assert runCPS(TestCases.list4()) == [3, 4, 2, 1]
  end

  test "tuple4" do
    assert runCPS(TestCases.tuple4()) == 1
  end

  test "assign9" do
    assert runCPS(TestCases.assign9()) == 183
  end

  test "struct1" do
    assert runCPS(TestCases.struct1()) == %Struto{x: 10, y: 20}
  end

  test "struct2" do
    assert runCPS(TestCases.struct2()) == 10
  end

  test "struct3" do
    assert runCPS(TestCases.struct3()) == 30
  end

  test "return_cont" do
    cont = runCPS(TestCases.return_cont())
    assert is_function(cont)
    assert runCPS(cont.(10)) == 21
  end

  test "multiple_cont_uses" do
    assert runCPS(TestCases.multiple_cont_uses()) == 12
  end

  test "field_access" do
    assert runCPS(TestCases.field_access()) == 10
  end

  test "field_access_cont1" do
    assert runCPS(TestCases.field_access_cont1()) == 20
  end

  test "field_access_cont2" do
    assert runCPS(TestCases.field_access_cont2()) == 52
  end

  test "field_access_cont3" do
    assert runCPS(TestCases.field_access_cont3()) == %{a: 22, b: 33}
  end

  test "multiple_shifts1" do
    assert runCPS(TestCases.multiple_shifts1()) == -16
  end

  test "multiple_shifts2" do
    assert runCPS(TestCases.multiple_shifts2()) == -16
  end

  test "nested_shifts_same_name1" do
    assert runCPS(TestCases.nested_shifts_same_name1()) == 6
  end

  test "nested_shifts_same_name2" do
    assert runCPS(TestCases.nested_shifts_same_name2()) == -7
  end

  test "nested_shifts_other_name1a" do
    assert runCPS(TestCases.nested_shifts_other_name1a()) == 4
  end

  test "nested_shifts_other_name1b" do
    assert runCPS(TestCases.nested_shifts_other_name1b()) == -7
  end

  test "conditional1" do
    assert runCPS(TestCases.conditional1(10)) == 1
    assert runCPS(TestCases.conditional1(-10)) == -1
  end

  test "conditional2" do
    assert runCPS(TestCases.conditional2(10)) == :non_negative
    assert runCPS(TestCases.conditional2(-10)) == :negative
  end

  test "conditional3" do
    assert runCPS(TestCases.conditional3(10)) == :non_negative
    assert runCPS(TestCases.conditional3(-10)) == nil
  end

  test "conditional4" do
    assert runCPS(TestCases.conditional4()) == :no
    assert_receive :true_branch
    assert_receive :false_branch
  end

  test "conditional5" do
    assert runCPS(TestCases.conditional5(21)) == :very_big
    assert runCPS(TestCases.conditional5(5)) == :medium
    assert runCPS(TestCases.conditional5(-7)) == :small
    assert runCPS(TestCases.conditional5(-14)) == :very_small
  end

  test "triples" do
    assert runCPS(TestCases.triples(9, 15)) == :no
    assert_receive {:found, {6, 5, 4}}
    assert_receive {:found, {7, 5, 3}}
    assert_receive {:found, {7, 6, 2}}
    assert_receive {:found, {8, 4, 3}}
    assert_receive {:found, {8, 5, 2}}
    assert_receive {:found, {8, 6, 1}}
    assert_receive {:found, {9, 4, 2}}
    assert_receive {:found, {9, 5, 1}}
  end

  test "ret_lambda1" do
    res = runCPS(TestCases.ret_lambda1())
    # return is a CPSed lambda
    assert is_function(res, 1)
    assert res.(& &1).().(& &1) == :res
  end

  test "ret_lambda2" do
    res = runCPS(TestCases.ret_lambda2())
    # return is a CPSed lambda
    assert is_function(res, 1)
    assert res.(& &1).(11).(& &1) == 1089
  end

  test "ret_lambda3" do
    res = runCPS(TestCases.ret_lambda3())
    # return is a CPSed lambda
    assert is_function(res, 1)
    # resulting lambda is curried
    assert res.(& &1).(9).(& &1).(11).(& &1) == -2
  end

  test "ret_lambda_compose1" do
    assert runCPS(TestCases.ret_lambda_compose1()) == :res
  end

  test "ret_lambda_compose2" do
    assert runCPS(TestCases.ret_lambda_compose2()) == 1089
  end

  test "ret_lambda_compose3" do
    assert runCPS(TestCases.ret_lambda_compose3()) == -2
  end

  test "app_lambda_directly1" do
    assert runCPS(TestCases.app_lambda_directly1()) == :res
  end

  test "app_lambda_directly2" do
    assert runCPS(TestCases.app_lambda_directly2()) == 1089
  end

  test "app_lambda_directly3" do
    assert runCPS(TestCases.app_lambda_directly3()) == 10
  end

  test "block_with_lambda1" do
    assert runCPS(TestCases.block_with_lambda1()) == :res
  end

  test "block_with_lambda2" do
    assert runCPS(TestCases.block_with_lambda2()) == 11
  end

  test "block_with_lambda3" do
    assert runCPS(TestCases.block_with_lambda3()) == -3
  end

  test "local_fn_call0" do
    assert runCPS(TestCases.local_fn_call0()) == :res
  end

  test "local_fn_call1" do
    assert runCPS(TestCases.local_fn_call1()) == 2
  end

  test "local_fn_call2" do
    assert runCPS(TestCases.local_fn_call2()) == 5
  end

  # this *must* be the last test
  test "coverage" do
    tests =
      @ex_unit_tests
      # subtract this test
      |> Stream.reject(&(&1.name == :"test coverage"))
      |> MapSet.new(fn %{name: test_name} ->
        "test " <> test_name = to_string(test_name)
        String.to_existing_atom(test_name)
      end)

    cases =
      MapSet.new(TestCases.__cps_functions__(), fn {fun, _arity} ->
        fun
      end)

    cases_without_tests = MapSet.difference(cases, tests)

    assert cases_without_tests == MapSet.new(),
      message: """
      missing tests for some cases
        #{Enum.join(cases_without_tests, "\n  ")}
      """
  end
end

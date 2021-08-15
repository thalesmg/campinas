defmodule OtherModule do
  import Campinas

  def plus1(x) do
    x + 1
  end

  defcps fail() do
    shift cont do
      :no
    end
  end

  defcps flip() do
    shift cont do
      cont(true)
      cont(false)
      @[fail()]
    end
  end

  defcps choice(n) do
    if n < 1 do
      @[fail()]
    else
      if @[flip()] do
        @[choice(n - 1)]
      else
        n
      end
    end
  end
end

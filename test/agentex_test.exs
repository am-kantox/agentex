defmodule Agentex.Test do
  @moduledoc false
  use ExUnit.Case
  doctest Agentex

  @count 1_000

  # require IEx
  # IEx.pry(1_000_000)

  test "put/get using different nodes" do
    nodes = Application.get_env(:agentex, :nodes, [Node.self | Node.list])
    size = Enum.count(nodes)

    Enum.each(1..@count, fn i ->
      Node.spawn(Enum.at(nodes, rem(i, size)), Agentex, :put, [:"key#{i}", i])
    end)

    Enum.each(1..@count, fn i ->
      get = Agentex.get(:"key#{i}")

      %Agentex.Simple.Kv{key: key, value: value} = get
      assert key == :"key#{i}"
      assert value == i

      assert i == Agentex.get!(:"key#{i}")
    end)

  end
end

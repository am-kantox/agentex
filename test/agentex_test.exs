defmodule Agentex.Test do
  @moduledoc false
  use ExUnit.Case
  doctest Agentex

  @count 5

  # require IEx
  # IEx.pry(1_000_000)

  test "put/get using different nodes" do
    Process.sleep(3_000)

    nodes = Application.get_env(:agentex, :nodes, [Node.self | Node.list])
    size = Enum.count(nodes)

    (1..@count)
    |> Enum.each(fn i ->
      Node.spawn(Enum.at(nodes, rem(i, size)), Agentex, :put, [:"key#{i}", i])
    end)

    # Process.sleep(3_000)

    (1..@count)
    |>  Enum.each(fn i ->
      assert i == Agentex.get :"key#{i}"
    end)

  end
end

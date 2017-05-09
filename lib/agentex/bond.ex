defmodule Agentex.Bond do
  @moduledoc false

  use GenServer
  use Agentex.Namer
  use Amnesia

  require Logger

  ##############################################################################

  def get(name, key) do
    name
    |> fqname()
    |> GenServer.call({:get, key!(key)})
  end

  def get!(name, key) do
    with %{value: value} <- get(name, key), do: value
  end

  def put(name, key, value) do
    GenServer.cast(fqname(name), {:put, {key!(key), value}})
  end

  ##############################################################################

  def start_link({db, [table]}), do: start_link({db, table})
  def start_link({db, table}) do
    GenServer.start_link(__MODULE__, Module.concat(db, table), name: fqname(table))
  end

  ##############################################################################

  def handle_call({:get, key}, _from, name) do
    key_value = Amnesia.transaction(do: apply(name, :read, [key]))
    {:reply, struct(name, key: key_value.key, value: key_value.value), name}
  end

  def handle_cast({:put, {key, value}}, name) do
    Amnesia.transaction(do: apply(name, :write, [struct(name, key: key, value: value)]))
    {:noreply, name}
  end

  ##############################################################################
  def key!(key, convertion \\ :none)

  def key!(key, :none), do: key

  def key!(key, :atom) when is_binary(key), do: String.to_atom(key)
  def key!(key, :atom) when is_atom(key), do: key

  def key!(key, :string) when is_binary(key), do: key
  def key!(key, :string) when is_atom(key), do: Atom.to_string(key)

end

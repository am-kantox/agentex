defmodule Agentex do
  @moduledoc ~S"""
  Distributed `Agent` implementation, providing multi-node agents on top of Mnesia.
  """

  use Amnesia
  defdatabase Simple do
    deftable Kv, [:key, :value], type: :ordered_set, index: [:value]
  end

  use Application
  use Agentex.DB

  defp initialize(preparation) do
    Amnesia.stop
    Amnesia.Schema.destroy

    if preparation[:drop], do: Mix.Tasks.Amnesia.Drop.run ["-d", Atom.to_string(@database)]
    if preparation[:create], do: Mix.Tasks.Amnesia.Create.run ["-d", Atom.to_string(@database), "--memory"]

    Amnesia.start
    apply(@database, :create!, [])
  end

  def start(_type, args) do
    import Supervisor.Spec, warn: false

    initialize(args)

    Supervisor.start_link(
      Enum.map(@bags,
          &worker(Agentex.Bond, [{@database, &1}], id: Module.concat([Agentex, Bond, @database, &1]))),
      [strategy: :one_for_one, name: Agentex.Supervisor])
  end

  ##############################################################################

  @doc ~S"""
  Retrieves the value for the given key and optional type.

  ## Examples

      iex> Agentex.put(:pi, 3.14)
      iex> Agentex.get!(:pi)
      3.14

      iex> Agentex.put(:rgb, %{r: 255, g: 0, b: 128})
      iex> Agentex.get(:rgb)
      %Agentex.Simple.Kv{key: :rgb, value: %{b: 128, g: 0, r: 255}}

      iex> Agentex.put(:rgb, %{r: 255, g: 0, b: 128})
      iex> Agentex.get(:rgb)
      %Agentex.Simple.Kv{key: :rgb, value: %{r: 255, g: 0, b: 128}}

      iex> Agentex.put(:rgb, %{r: 255, g: 0, b: 128})
      iex> Agentex.get!(:rgb)
      %{r: 255, g: 0, b: 128}

      iex> Agentex.put(:rrr, [r: 255, r: 0, r: 128])
      iex> Agentex.get!(:rrr)
      [r: 255, r: 0, r: 128]

      iex> Agentex.put(:rrr, [{:r, 255}, {:r, 0}, {:r, 128}])
      iex> Agentex.get!(:rrr)
      [r: 255, r: 0, r: 128]
  """
  def get(name \\ Agentex.Namer.table(@bags), key)
  def get([name], key), do: get(name, key)
  def get(name, key), do: Agentex.Bond.get(name, key)

  def get!(name \\ Agentex.Namer.table(@bags), key)
  def get!([name], key), do: get!(name, key)
  def get!(name, key), do: Agentex.Bond.get!(name, key)

  def put(name \\ Agentex.Namer.table(@bags), key, value)
  def put([name], key, value), do: put(name, key, value)
  def put(name, key, value), do: Agentex.Bond.put(name, key, value)

  ##############################################################################
end

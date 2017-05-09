use Amnesia

defmodule Agentex do
  @moduledoc ~S"""
  Distributed `Agent` implementation, providing multi-node agents on top of Mnesia.
  """


  use Application
  use Agentex.DB

  require IEx
  IEx.pry(1_000_000)

  def initialize(preparation \\ []) do
    if preparation[:drop], do: Mix.Tasks.Amnesia.Drop.run ["-d", Atom.to_string(@database)]
    if preparation[:create], do: Mix.Tasks.Amnesia.Create.run ["-d", Atom.to_string(@database), "--memory"]
  end

  def start(_type, args) do
    import Supervisor.Spec, warn: false

    initialize(args)

    Supervisor.start_link(
      Enum.map(Agentex.Namer.tables(@table),
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
      %{key: :rgb, value: %{r: 255, g: 0, b: 128}}

      iex> Agentex.put(Store, :rgb, %{r: 255, g: 0, b: 128})
      iex> Agentex.get(Store, :rgb)
      %{key: :rgb, value: %{r: 255, g: 0, b: 128}}

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
  def get(name \\ Agentex.Namer.table(@table), key)
  def get([name], key), do: get(name, key)
  def get(name, key), do: Agentex.Bond.get(name, key)

  def get!(name \\ Agentex.Namer.table(@table), key)
  def get!([name], key), do: get!(name, key)
  def get!(name, key), do: Agentex.Bond.get!(name, key)

  def put(name \\ Agentex.Namer.table(@table), key, value)
  def put([name], key, value), do: put(name, key, value)
  def put(name, key, value), do: Agentex.Bond.put(name, key, value)

  ##############################################################################
end

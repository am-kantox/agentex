defmodule Agentex do
  @moduledoc ~S"""
  Distributed `Agent` implementation, providing multi-node agents on top of Mnesia.

  More on starting distributed apps:
    http://engineering.pivotal.io/post/how-to-set-up-an-elixir-cluster-on-amazon-ec2/

  More on `mnesia`:
    http://learnyousomeerlang.com/mnesia
  """

  use Application
  require Logger

  @sleep_time 1_000
  @default_table Agentex.Simple.Kv

  defp nodes do
    self = node()
    nodes = :agentex
            |> Application.get_env(:nodes, [self])
            |> Enum.filter(fn
                  ^self -> false
                  _ -> true
               end)
    Logger.debug(fn -> "☆#{inspect node()}☆ ⇒ nodes are: #{inspect nodes}" end)
    wait_for_nodes = Application.get_env(:agentex, :wait_for_nodes, 30_000)
    attempts = Integer.floor_div(wait_for_nodes, @sleep_time) + 1
    Enum.any?(1..attempts, fn i ->
      Process.sleep(@sleep_time)
      Enum.each(nodes, &Node.connect/1)
      Logger.debug(fn -> "Attempt ##{i}. Nodes: #{inspect Node.list}" end)
      Enum.count(Node.list) == Enum.count(nodes)
    end)

    nodes = [self | Node.list]
    i_am_chuck_norris = case Enum.sort(nodes) do
                          [^self | _] -> true
                          _ -> false
                        end
    {:ok, {i_am_chuck_norris, nodes}}
  end

  defp initialize(preparation) do
    Amnesia.stop
    Amnesia.Schema.destroy

    # if preparation[:drop], do: Mix.Tasks.Amnesia.Drop.run ["-d", Atom.to_string(@database)]
    # if preparation[:create], do: Mix.Tasks.Amnesia.Create.run ["-d", Atom.to_string(@database), "--memory"]

    {:ok, {i_am_chuck_norris, nodes}} = nodes()
    Logger.info(fn -> "★★★ Nodes connected: #{inspect nodes}" end)

    if i_am_chuck_norris, do: Logger.warn "☆☆☆ I am Chuck Norris!"

    Amnesia.Schema.create(nodes)
    database = Application.get_env(:agentex, :database, Agentex.Simple)
    if database == Agentex.Simple, do: use(Agentex.DB)

    :rpc.multicall(nodes, Amnesia, :start, [])
    if i_am_chuck_norris, do: apply(database, :create!, [])

    database
  end

  def start(_type, args) do
    import Supervisor.Spec, warn: false

    database = initialize(args)

    Supervisor.start_link(
      Enum.map(apply(database, :tables, []),
        &worker(Agentex.Bond, [{database, &1}], id: Module.concat([Agentex, Bond, database, &1]))),
      [strategy: :one_for_one, name: Agentex.Supervisor])
  end

  def stop(_state) do
    case nodes() do
      {:ok, {true, _}} ->
        database = Application.get_env(:agentex, :database, Agentex.Simple)
        apply(database, :destroy!, [])
        :ok
      _ -> :ok
    end
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
  def get(name \\ Agentex.Namer.table(@default_table), key)
  def get([name], key), do: get(name, key)
  def get(name, key), do: Agentex.Bond.get(name, key)

  def get!(name \\ Agentex.Namer.table(@default_table), key)
  def get!([name], key), do: get!(name, key)
  def get!(name, key), do: Agentex.Bond.get!(name, key)

  def put(name \\ Agentex.Namer.table(@default_table), key, value)
  def put([name], key, value), do: put(name, key, value)
  def put(name, key, value), do: Agentex.Bond.put(name, key, value)

  ##############################################################################
end

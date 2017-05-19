ExUnit.start()

Amnesia.debug(:trace)
# Agentex.start(:normal, [])
IO.inspect Node.list, label: "☆☆☆ Node list"

# Node.list
# |> Enum.each(&Node.spawn(fn -> ))
# IO.inspect :rpc.multicall(Node.list, Application, :ensure_all_started, [:agentex]), label: "☆☆☆ Application.ensure"
# IO.inspect :rpc.multicall(Node.list, Application, :started_applications, []), label: "☆☆☆ Application.started"
# IO.inspect :rpc.multicall(Node.list, Agentex, :start, [:normal, []]), label: "☆☆☆ Agentex.start"

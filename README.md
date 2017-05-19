# Agentex

**Elixir distributed agent implementation on top of Mnesia**

## Installation

In **mix.exs**:

```elixir
def deps do
  [
    ...
    {:agentex, "~> 0.1"}
  ]
end

def application do
    [
      ...
      applications: [
        ...
        :agentex
      ]
end
```

## Preparation

### Schema

```sh
$ iex --cookie agentex -S mix run.distributed
  Erlang/OTP 19 [erts-8.3] [...]

Interactive Elixir (1.5.0-dev) - [...]
iex(primary@127.0.0.1)1> nodes = [Node.self | Node.list]                
iex(primary@127.0.0.1)2> Amnesia.stop
:stopped
iex(primary@127.0.0.1)3> :rpc.multicall(nodes, Amnesia, :stop, [])
{[:stopped, :stopped, :stopped, :stopped, :stopped], []}
iex(primary@127.0.0.1)4> Amnesia.Schema.destroy
:ok
iex(primary@127.0.0.1)5> Amnesia.Schema.create(nodes)
:ok
```

## Usage

```elixir
Agentex.put :pi, 3.14
Agentex.get :pi
#⇒ 3.14
Agentex.put :credentials, %{user: "john", pass: "*********"}
Agentex.get :credentials
#⇒ %{user: "john", pass: "*********"}
```

## Distributed usage

**config.exs**
```elixir
config :agentex, :nodes, ~w|n1@127.0.0.1 n2@127.0.0.1|a
```

Make sure, the `Agentex` application with the same config is starting
on all the nodes listed. The first node would be considered “master” node.
It will be used to produce schema and re-create tables on each subsequent
application restart.

By default, the only database `Agentex.Simple` with the single table
`Agentex.Simple.Kv` of type `key ⇒ value` is being created, though one might
specify their own database, containing as many tables as needed.

In the latter case, to distinguish `Agentex.{get,put}` calls between
different tables, the table module atom should be specified as the very
first parameter:

```elixir
Agentex.put Agentex.Db.Math, :pi, 3.14
Agentex.get Agentex.Db.Math, :pi
#⇒ 3.14
```

---
Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/agentex](https://hexdocs.pm/agentex).

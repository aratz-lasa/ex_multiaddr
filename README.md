# ex-multiaddr
[IPFS multiaddr](https://multiformats.io/multiaddr/) implementation in Elixir [under development]

## Installation
Not yet published.

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_multiaddr` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_multiaddr, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_multiaddr](https://hexdocs.pm/ex_multiaddr).

## Usage

### Create Multiaddr
```elixir
def main do
  maddr_string = "/ip4/127.0.0.1/tcp/80"
  {:ok, maddr} = Multiaddr.new_multiaddr_from_string(maddr_string)
end
```

### Inspect Multiaddr
```elixir
def main do
  protocols = Multiaddr.protocols(maddr)
  assert length(protocols) == 2
  {:ok, prot_1} = Enum.fetch(protocols, 0)
  assert prot_1 == Multiaddr.Protocol.proto_ip4()

  {:ok, ip4_value} = Multiaddr.value_for_protocol(maddr, Multiaddr.Protocol.proto_ip4().code)
  {:ok, tcp_value} = Multiaddr.value_for_protocol(maddr, Multiaddr.Protocol.proto_tcp().code)
  assert ip4_value == "127.0.0.1"
  assert tcp_value == "80"
end
```

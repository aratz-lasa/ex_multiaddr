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

## Protocols
- [X] ip4
- [X] tcp
- [X] udp
- [X] dccp
- [X] ip6
- [X] ip6zone
- [X] dns
- [X] dns4
- [X] dns6
- [X] dnsaddr
- [X] sctp
- [ ] udt
- [ ] utp
- [ ] unix
- [ ] p2p
- [ ] ipfs
- [ ] onion
- [ ] onion3
- [ ] garlic64
- [ ] garlic32
- [ ] quic
- [ ] http
- [ ] https
- [ ] ws
- [ ] wss
- [ ] p2p-websocket-star
- [ ] p2p-stardust
- [ ] p2p-webrtc-star
- [ ] p2p-webrtc-direct
- [ ] p2p-circuit
- [ ] memory



## Usage

### Create Multiaddr
```elixir
maddr_string = "/ip4/127.0.0.1/tcp/80"
{:ok, maddr} = Multiaddr.new_multiaddr_from_string(maddr_string)
# {:ok, %Multiaddr{bytes: <<4, 127, 0, 0, 1, 6, 0, 80>>}}
## 
```

### En/Decapsulate
```Elixir
{:ok, maddr_1} = Multiaddr.new_multiaddr_from_string("/ip4/127.0.0.1")
{:ok, maddr_2} = Multiaddr.new_multiaddr_from_string("/tcp/80")
{:ok, maddr_en} = Multiaddr.encapsulate(maddr_1, maddr_2)
# {:ok, %Multiaddr{bytes: <<4, 127, 0, 0, 1, 6, 0, 80>>}}
Multiaddr.string(maddr_en)
# "/ip4/127.0.0.1/tcp/80"

{:ok, maddr_de} = Multiaddr.decapsulate(maddr_en, maddr_2)
# {:ok, %Multiaddr{bytes: <<4, 127, 0, 0, 1>>}}
Multiaddr.string(maddr_de)
# "/ip4/127.0.0.1"
```

### Inspect Multiaddr
```elixir
{:ok, maddr} = Multiaddr.new_multiaddr_from_string("/ip4/127.0.0.1/tcp/80")
protocols = Multiaddr.protocols(maddr)

{:ok, prot_1} = Enum.fetch(protocols, 0)
#{:ok, %Multiaddr.Protocol{
#   code: 4, name: "ip4", size: 32,
#   transcoder: %Multiaddr.Transcoder{
#     bytes_to_string: #Function<2.41508498/1 in Multiaddr.Transcoder.ip4_transcoder/0>,
#     string_to_bytes: #Function<3.41508498/1 in Multiaddr.Transcoder.ip4_transcoder/0>
#   },
#   vcode: <<4>>
# }}
{:ok, ip4_value} = Multiaddr.value_for_protocol(maddr, "ip4")
# {:ok, "127.0.0.1"}
{:ok, tcp_value} = Multiaddr.value_for_protocol(maddr, "tcp")
# {:ok, "80"}
```

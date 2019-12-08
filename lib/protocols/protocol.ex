defmodule Multiaddr.Protocol do
  import Multiaddr.Utils.Constants, only: :macros
  import Multiaddr.Protocol.Codes
  alias Multiaddr.Varint

  defstruct [:name, :code, :vcode, :size, :transcoder]

  define(:proto_ip4, %__MODULE__{name: "ip4", code: c_ip4(), vcode: Varint.code_to_varint(c_ip4()), size: 32, transcoder: nil})
  define(:proto_tcp, %__MODULE__{name: "tcp", code: c_tcp(), vcode: Varint.code_to_varint(c_tcp()), size: 16, transcoder: nil})

  define(:protocols_by_code,%{
    c_ip4() => proto_ip4(),
    c_tcp() => proto_tcp()
  })

  define(:protocols_by_name, %{
    proto_ip4().name => proto_ip4(),
    proto_tcp().name => proto_tcp(),
  })

end

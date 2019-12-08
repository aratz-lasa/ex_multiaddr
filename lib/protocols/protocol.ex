defmodule Multiaddr.Protocol do
  import Multiaddr.Utils.Constants, only: :macros
  import Multiaddr.Protocol.Codes
  alias Multiaddr.Transcoder
  alias Multiaddr.Varint

  defstruct [:name, :code, :vcode, :size, :transcoder]

  define(:proto_ip4, %__MODULE__{
    name: "ip4",
    code: c_ip4(),
    vcode: Varint.code_to_varint(c_ip4()),
    size: 32,
    transcoder: Transcoder.ip4_transcoder()
  })

  define(:proto_tcp, %__MODULE__{
    name: "tcp",
    code: c_tcp(),
    vcode: Varint.code_to_varint(c_tcp()),
    size: 16,
    transcoder: Transcoder.port_transcoder()
  })

  define(:protocols_by_code, %{
    proto_ip4().code => proto_ip4(),
    proto_tcp().code => proto_tcp()
  })

  define(:protocols_by_name, %{
    proto_ip4().name => proto_ip4(),
    proto_tcp().name => proto_tcp()
  })
end

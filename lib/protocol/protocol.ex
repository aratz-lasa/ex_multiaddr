defmodule Multiaddr.Protocol do
  import Multiaddr.Utils.Constants, only: :macros
  import Multiaddr.Protocol.Codes
  alias Multiaddr.Transcoder
  alias Multiaddr.Utils.Varint

  defstruct [:name, :code, :vcode, :size, :transcoder]

  define(:proto_ip4, %__MODULE__{
    name: "ip4",
    code: c_ip4(),
    vcode: Varint.code_to_varint(c_ip4()),
    size: 32,
    transcoder: Transcoder.ip4_transcoder()
  })

  define(:proto_ip6, %__MODULE__{
    name: "ip6",
    code: c_ip6(),
    vcode: Varint.code_to_varint(c_ip6()),
    size: 128,
    transcoder: Transcoder.ip6_transcoder()
  })

  define(:proto_tcp, %__MODULE__{
    name: "tcp",
    code: c_tcp(),
    vcode: Varint.code_to_varint(c_tcp()),
    size: 16,
    transcoder: Transcoder.port_transcoder()
  })

  define(:proto_udp, %__MODULE__{
    name: "udp",
    code: c_udp(),
    vcode: Varint.code_to_varint(c_udp()),
    size: 16,
    transcoder: Transcoder.port_transcoder()
  })

  define(:proto_dccp, %__MODULE__{
    name: "dccp",
    code: c_dccp(),
    vcode: Varint.code_to_varint(c_dccp()),
    size: 16,
    transcoder: Transcoder.port_transcoder()
  })

  define(:proto_sctp, %__MODULE__{
    name: "sctp",
    code: c_sctp(),
    vcode: Varint.code_to_varint(c_sctp()),
    size: 16,
    transcoder: Transcoder.port_transcoder()
  })

  define(:protocols_by_code, %{
    proto_ip4().code => proto_ip4(),
    proto_ip6().code => proto_ip6(),
    proto_tcp().code => proto_tcp(),
    proto_udp().code => proto_udp(),
    proto_dccp().code => proto_dccp(),
    proto_sctp().code => proto_sctp()
  })

  define(:protocols_by_name, %{
    proto_ip4().name => proto_ip4(),
    proto_ip6().name => proto_ip6(),
    proto_tcp().name => proto_tcp(),
    proto_udp().name => proto_udp(),
    proto_dccp().name => proto_dccp(),
    proto_sctp().name => proto_sctp()
  })
end

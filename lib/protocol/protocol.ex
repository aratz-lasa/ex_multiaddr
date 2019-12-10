defmodule Multiaddr.Protocol do
  import Multiaddr.Utils.Constants, only: :macros
  import Multiaddr.Protocol.Codes
  alias Multiaddr.Transcoder
  alias Multiaddr.Utils.Varint

  defstruct [:name, :code, :vcode, :transcoder, size: 0]

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

  define(:proto_ip6, %__MODULE__{
    name: "ip6",
    code: c_ip6(),
    vcode: Varint.code_to_varint(c_ip6()),
    size: 128,
    transcoder: Transcoder.ip6_transcoder()
  })

  define(:proto_ip6zone, %__MODULE__{
    name: "ip6zone",
    code: c_ip6zone(),
    vcode: Varint.code_to_varint(c_ip6zone()),
    size: :prefixed_var_size,
    transcoder: Transcoder.text_transcoder()
  })

  define(:proto_dns, %__MODULE__{
    name: "dns",
    code: c_dns(),
    vcode: Varint.code_to_varint(c_dns()),
    size: :prefixed_var_size,
    transcoder: Transcoder.text_transcoder()
  })

  define(:proto_dns4, %__MODULE__{
    name: "dns4",
    code: c_dns4(),
    vcode: Varint.code_to_varint(c_dns4()),
    size: :prefixed_var_size,
    transcoder: Transcoder.text_transcoder()
  })

  define(:proto_dns6, %__MODULE__{
    name: "dns6",
    code: c_dns6(),
    vcode: Varint.code_to_varint(c_dns6()),
    size: :prefixed_var_size,
    transcoder: Transcoder.text_transcoder()
  })

  define(:proto_dnsaddr, %__MODULE__{
    name: "dnsaddr",
    code: c_dnsaddr(),
    vcode: Varint.code_to_varint(c_dnsaddr()),
    size: :prefixed_var_size,
    transcoder: Transcoder.text_transcoder()
  })

  define(:proto_sctp, %__MODULE__{
    name: "sctp",
    code: c_sctp(),
    vcode: Varint.code_to_varint(c_sctp()),
    size: 16,
    transcoder: Transcoder.port_transcoder()
  })

  define(:proto_udt, %__MODULE__{
    name: "udt",
    code: c_udt(),
    vcode: Varint.code_to_varint(c_udt())
  })

  define(:proto_utp, %__MODULE__{
    name: "utp",
    code: c_utp(),
    vcode: Varint.code_to_varint(c_utp())
  })


  define(:proto_quic, %__MODULE__{
    name: "quic",
    code: c_quic(),
    vcode: Varint.code_to_varint(c_quic())
  })

  define(:proto_http, %__MODULE__{
    name: "http",
    code: c_http(),
    vcode: Varint.code_to_varint(c_http())
  })

  define(:proto_https, %__MODULE__{
    name: "https",
    code: c_https(),
    vcode: Varint.code_to_varint(c_https())
  })
  define(:proto_ws, %__MODULE__{
    name: "ws",
    code: c_ws(),
    vcode: Varint.code_to_varint(c_ws())
  })

  define(:protocols_by_code, %{
    proto_ip4().code => proto_ip4(),
    proto_tcp().code => proto_tcp(),
    proto_udp().code => proto_udp(),
    proto_dccp().code => proto_dccp(),
    proto_ip6().code => proto_ip6(),
    proto_ip6zone().code => proto_ip6zone(),
    proto_dns().code => proto_dns(),
    proto_dns4().code => proto_dns4(),
    proto_dns6().code => proto_dns6(),
    proto_dnsaddr().code => proto_dnsaddr(),
    proto_sctp().code => proto_sctp(),
    proto_udt().code => proto_udt(),
    proto_utp().code => proto_utp(),
    proto_quic().code => proto_quic(),
    proto_http().code => proto_http(),
    proto_https().code => proto_https(),
    proto_ws().code => proto_ws(),
  })

  define(:protocols_by_name, %{
    proto_ip4().name => proto_ip4(),
    proto_tcp().name => proto_tcp(),
    proto_udp().name => proto_udp(),
    proto_dccp().name => proto_dccp(),
    proto_ip6().name => proto_ip6(),
    proto_ip6zone().name => proto_ip6zone(),
    proto_dns().name => proto_dns(),
    proto_dns4().name => proto_dns4(),
    proto_dns6().name => proto_dns6(),
    proto_dnsaddr().name => proto_dnsaddr(),
    proto_sctp().name => proto_sctp(),
    proto_udt().name => proto_udt(),
    proto_utp().name => proto_utp(),
    proto_quic().name => proto_quic(),
    proto_http().name => proto_http(),
    proto_https().name => proto_https(),
    proto_ws().name => proto_ws(),
  })
end

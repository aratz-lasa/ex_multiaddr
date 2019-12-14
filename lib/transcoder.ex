defmodule Multiaddr.Transcoder do
  @moduledoc false

  import Multiaddr.Utils
  import Multiaddr.Utils.Constants

  defstruct [:bytes_to_string, :string_to_bytes, :validate_bytes]

  # Text
  def text_bytes_to_string(bytes) when is_binary(bytes) do
    if valid_text?(bytes) do
      {:ok, bytes}
    else
      {:error, {:invalid_bytes, "Invalid text bytes. Must be a 'text' and not contain '/'"}}
    end
  end

  def text_string_to_bytes(string) when is_binary(string) do
    if valid_text?(string) do
      {:ok, string}
    else
      {:error, {:invalid_bytes, "Invalid text string. Must be a 'text' and not contain '/'"}}
    end
  end

  def text_validate_bytes(bytes) when is_binary(bytes) do
    if valid_text?(bytes) do
      {:ok, bytes}
    else
      {:error, {:invalid_bytes, "Invalid text bytes. Must be a 'text' and not contain '/'"}}
    end
  end

  def valid_text?(string) when is_binary(string) do
    with true <- 0 < String.length(string),
         true <- String.valid?(string),
         false <- String.contains?(string, "/") do
      true
    else
      _ -> false
    end
  end

  # IP4
  def ip4_bytes_to_string(bytes) when is_binary(bytes) do
    string =
      bytes
      |> :binary.bin_to_list()
      |> Enum.join(".")

    case to_charlist(string) |> :inet.parse_ipv4_address() do
      {:ok, _ip} -> {:ok, string}
      _error -> {:error, {:invalid_bytes, "Invalid IPv4 bytes"}}
    end
  end

  def ip4_string_to_bytes(string) when is_binary(string) do
    case to_charlist(string) |> :inet.parse_ipv4_address() do
      {:ok, ip} ->
        string = ip |> Tuple.to_list() |> :binary.list_to_bin()
        {:ok, string}

      _error ->
        {:error, {:invalid_string, "Invalid IPv4 string: #{string}"}}
    end
  end

  def ip4_validate_bytes(bytes) when is_binary(bytes) do
    case ip4_bytes_to_string(bytes) do
      {:ok, _string} -> {:ok, bytes}
      error -> error
    end
  end

  # IP6
  def ip6_bytes_to_string(bytes) when is_binary(bytes) do
    try do
      string =
        bytes
        |> :binary.bin_to_list()
        |> Enum.chunk_every(2)
        |> Enum.map(&:binary.list_to_bin/1)
        |> Enum.map(fn x ->
          <<integer::size(16)>> = x
          integer
        end)
        |> Enum.join(":")

      case to_charlist(string) |> :inet.parse_ipv6_address() do
        {:ok, _ip} -> {:ok, string}
        _error -> {:error, {:invalid_bytes, "Invalid IPv6 bytes"}}
      end
    rescue
      MatchError -> {:error, {:invalid_bytes, "Invalid IPv6 bytes."}}
    end
  end

  def ip6_string_to_bytes(string) when is_binary(string) do
    try do
      case to_charlist(string) |> :inet.parse_ipv6_address() do
        {:ok, ip} ->
          bytes =
            ip
            |> Tuple.to_list()
            |> Enum.map(fn x -> <<x::size(16)>> end)
            |> :binary.list_to_bin()

          {:ok, bytes}

        _error ->
          {:error, {:invalid_string, "Invalid IPv6 string: #{string}"}}
      end
    rescue
      MatchError -> {:error, {:invalid_string, "Invalid IPv6 string: #{string}"}}
    end
  end

  def ip6_validate_bytes(bytes) when is_binary(bytes) do
    case ip6_bytes_to_string(bytes) do
      {:ok, _string} -> {:ok, bytes}
      error -> error
    end
  end

  # Port
  def port_bytes_to_string(bytes) when is_binary(bytes) do
    try do
      <<integer::size(16)>> = bytes
      string = to_string(integer)
      {:ok, string}
    rescue
      MatchError -> {:error, {:invalid_bytes, "Invalid port bytes(TCP/UDP etc.)"}}
    end
  end

  def port_string_to_bytes(string) when is_binary(string) do
    try do
      integer = String.to_integer(string)

      true = integer < 65536
      bytes = <<integer::size(16)>>
      {:ok, bytes}
    rescue
      _error -> {:error, {:invalid_string, "Invalid port string: #{string}"}}
    end
  end

  def port_validate_bytes(bytes) when is_binary(bytes) do
    case port_bytes_to_string(bytes) do
      {:ok, _string} -> {:ok, bytes}
      error -> error
    end
  end

  # Path
  def path_string_to_bytes(string) when is_binary(string) do
    if valid_path?(string) do
      {:ok, string}
    else
      {:error, {:invalid_string, "Invalid path string: #{string}"}}
    end
  end

  def path_bytes_to_string(bytes) when is_binary(bytes) do
    if valid_path?(bytes) do
      {:ok, bytes}
    else
      {:error, {:invalid_bytes, "Invalid path bytes"}}
    end
  end

  def path_validate_bytes(bytes) when is_binary(bytes) do
    if valid_path?(bytes) do
      {:ok, bytes}
    else
      {:error, {:invalid_bytes, "Invalid path bytes"}}
    end
  end

  def valid_path?(path) when is_binary(path) do
    with true <- 0 < String.length(path),
         true <- String.valid?(path) do
      true
    else
      _ -> false
    end
  end

  # P2P/IPFS
  def p2p_string_to_bytes(string) when is_binary(string) do
    with true <- String.valid?(string),
         {:ok, decoded_bytes} <- B58.decode58(string),
         {:ok, _multihash} <- Multihash.decode(decoded_bytes) do
      {:ok, decoded_bytes}
    else
      _error -> {:error, {:invalid_string, "Invalid P2P/IPFS string: #{string}"}}
    end
  end

  def p2p_bytes_to_string(bytes) when is_binary(bytes) do
    with {:ok, _multihash} <- Multihash.decode(bytes),
         encoded_string <- B58.encode58(bytes) do
      {:ok, encoded_string}
    else
      _error -> {:error, {:invalid_bytes, "Invalid P2P/IPFS bytes"}}
    end
  end

  def p2p_validate_bytes(bytes) when is_binary(bytes) do
    case p2p_bytes_to_string(bytes) do
      {:ok, _string} -> {:ok, bytes}
      error -> error
    end
  end

  # Onion
  def onion_string_to_bytes(string) when is_binary(string) do
    try do
      with true <- String.valid?(string),
           [host, port_string] <- String.split(string, ":"),
           16 <- String.length(host),
           {:ok, host_bytes} <- Base.decode32(host, case: :lower),
           port <- String.to_integer(port_string),
           true <- 0 < port and port < 65536,
           port_bytes <- <<port::16-big>> do
        {:ok, host_bytes <> port_bytes}
      else
        _error -> {:error, {:invalid_bytes, "Invalid Onion string: #{string}"}}
      end
    rescue
      _error -> {:error, {:invalid_bytes, "Invalid Onion string: #{string}"}}
    end
  end

  def onion_bytes_to_string(bytes) when is_binary(bytes) do
    host_string =
      bytes
      |> String.slice(0..9)
      |> Base.encode32(case: :lower)

    if host_string == :error do
      {:error, {:invalid_bytes, "Invalid Onion bytes"}}
    else
      try do
        <<port::16-big>> = String.slice(bytes, 10..-1)
        {:ok, "#{host_string}:#{port}"}
      rescue
        _error -> {:error, {:invalid_bytes, "Invalid Onion bytes"}}
      end
    end
  end

  def onion_validate_bytes(bytes) when is_binary(bytes) do
    case onion3_bytes_to_string(bytes) do
      {:ok, _string} -> {:ok, bytes}
      error -> error
    end
  end

  # Onion3
  def onion3_string_to_bytes(string) when is_binary(string) do
    try do
      with true <- String.valid?(string),
           [host, port_string] <- String.split(string, ":"),
           56 <- String.length(host),
           {:ok, host_bytes} <- Base.decode32(host, case: :lower),
           port <- String.to_integer(port_string),
           true <- 0 < port and port < 65536,
           port_bytes <- <<port::16-big>> do
        {:ok, host_bytes <> port_bytes}
      else
        _error -> {:error, {:invalid_bytes, "Invalid Onion3 string: #{string}"}}
      end
    rescue
      _error -> {:error, {:invalid_bytes, "Invalid Onion3 string: #{string}"}}
    end
  end

  def onion3_bytes_to_string(bytes) when is_binary(bytes) do
    host_string =
      bytes
      |> String.slice(0..34)
      |> Base.encode32(case: :lower)

    if host_string == :error do
      {:error, {:invalid_bytes, "Invalid Onion3 bytes"}}
    else
      try do
        <<port::16-big>> = String.slice(bytes, 35..-1)
        {:ok, "#{host_string}:#{port}"}
      rescue
        _error -> {:error, {:invalid_bytes, "Invalid Onion3 bytes"}}
      end
    end
  end

  def onion3_validate_bytes(bytes) when is_binary(bytes) do
    case onion3_bytes_to_string(bytes) do
      {:ok, _string} -> {:ok, bytes}
      error -> error
    end
  end

  # Garlic64
  def garlic64_string_to_bytes(string) when is_binary(string) do
    with true <- String.valid?(string),
         true <- 516 <= String.length(string),
         true <- String.length(string) <= 616 do
      try do
        i2p_decode64(string)
      rescue
        _error -> {:error, {:invalid_bytes, "Invalid Garlic64 string: #{string}"}}
      end
    else
      false -> {:error, {:invalid_bytes, "Invalid Garlic64 string: #{string}"}}
    end
  end

  def garlic64_bytes_to_string(bytes) when is_binary(bytes) do
    with {:ok, string} <- i2p_encode64(bytes),
         true <- 516 <= String.length(string),
         true <- String.length(string) <= 616 do
      {:ok, string}
    else
      _error -> {:error, {:invalid_bytes, "Invalid Garlic64 bytes"}}
    end
  end

  def garlic64_validate_bytes(bytes) when is_binary(bytes) do
    case garlic64_bytes_to_string(bytes) do
      {:ok, _string} -> {:ok, bytes}
      error -> error
    end
  end

  # Garlic32
  def garlic32_string_to_bytes(string) when is_binary(string) do
    with true <- String.valid?(string),
         true <- 55 < String.length(string) or String.length(string) == 52 do
      case Base.decode32(string, case: :lower, padding: false) do
        :error ->
          {:error,
           {:invalid_bytes, "Invalid Garlic32 string. Failed to decode Base 32: #{string}"}}

        {:ok, decoded_bytes} ->
          {:ok, decoded_bytes}
      end
    else
      _error ->
        {:error,
         {:invalid_bytes,
          "Invalid Garlic32 string. Not correct size, must be <55 or ==52, not #{
            String.length(string)
          } "}}
    end
  end

  def garlic32_bytes_to_string(bytes) when is_binary(bytes) do
    with true <- 35 <= byte_size(bytes) or byte_size(bytes) == 32 do
      string = bytes |> Base.encode32(case: :lower, padding: false) |> String.trim_trailing("=")
      {:ok, string}
    else
      _error -> {:error, {:invalid_bytes, "Invalid Garlic32 bytes"}}
    end
  end

  def garlic32_validate_bytes(bytes) when is_binary(bytes) do
    case garlic32_bytes_to_string(bytes) do
      {:ok, _string} -> {:ok, bytes}
      error -> error
    end
  end

  define(:ip4_transcoder, %__MODULE__{
    bytes_to_string: &ip4_bytes_to_string/1,
    string_to_bytes: &ip4_string_to_bytes/1,
    validate_bytes: &ip4_validate_bytes/1
  })

  define(:ip6_transcoder, %__MODULE__{
    bytes_to_string: &ip6_bytes_to_string/1,
    string_to_bytes: &ip6_string_to_bytes/1,
    validate_bytes: &ip6_validate_bytes/1
  })

  define(:port_transcoder, %__MODULE__{
    bytes_to_string: &port_bytes_to_string/1,
    string_to_bytes: &port_string_to_bytes/1,
    validate_bytes: &port_validate_bytes/1
  })

  define(:text_transcoder, %__MODULE__{
    bytes_to_string: &text_bytes_to_string/1,
    string_to_bytes: &text_string_to_bytes/1,
    validate_bytes: &text_validate_bytes/1
  })

  define(:path_transcoder, %__MODULE__{
    bytes_to_string: &path_bytes_to_string/1,
    string_to_bytes: &path_string_to_bytes/1,
    validate_bytes: &path_validate_bytes/1
  })

  define(:p2p_transcoder, %__MODULE__{
    bytes_to_string: &p2p_bytes_to_string/1,
    string_to_bytes: &p2p_string_to_bytes/1,
    validate_bytes: &p2p_validate_bytes/1
  })

  define(:onion_transcoder, %__MODULE__{
    bytes_to_string: &onion_bytes_to_string/1,
    string_to_bytes: &onion_string_to_bytes/1,
    validate_bytes: &onion_validate_bytes/1
  })

  define(:onion3_transcoder, %__MODULE__{
    bytes_to_string: &onion3_bytes_to_string/1,
    string_to_bytes: &onion3_string_to_bytes/1,
    validate_bytes: &onion3_validate_bytes/1
  })

  define(:garlic64_transcoder, %__MODULE__{
    bytes_to_string: &garlic64_bytes_to_string/1,
    string_to_bytes: &garlic64_string_to_bytes/1,
    validate_bytes: &garlic64_validate_bytes/1
  })

  define(:garlic32_transcoder, %__MODULE__{
    bytes_to_string: &garlic32_bytes_to_string/1,
    string_to_bytes: &garlic32_string_to_bytes/1,
    validate_bytes: &garlic32_validate_bytes/1
  })
end

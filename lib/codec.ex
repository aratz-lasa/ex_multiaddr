defmodule Multiaddr.Codec do
  import Multiaddr.Varint
  import Multiaddr.Utils
  alias Multiaddr.Protocol, as: Prot

  defp extract_protocols(bytes, protocols_list) when bytes == <<>> do
    {:ok, protocols_list}
  end

  defp extract_protocols(bytes, protocols_list) when is_binary(bytes) do
    case read_protocol(bytes) do
      {:ok, next_index, {protocol, _value}} ->
        extract_protocols(split_binary(bytes, next_index..-1), protocols_list ++ [protocol])

      _ ->
        {:error, "Invalid Multiaddr"}
    end
  end

  def extract_protocols(bytes) when is_binary(bytes) do
    extract_protocols(bytes, [])
  end

  def validate_bytes(bytes) when bytes == <<>> do
    {:ok, "Valid bytes"}
  end

  def validate_bytes(bytes) when is_binary(bytes) do
    case read_protocol(bytes) do
      {:ok, next_index, {_protocol, _value}} ->
        validate_bytes(split_binary(bytes, next_index..-1))

      _ ->
        {:error, "Invalid Multiaddr"}
    end
  end

  def string_to_bytes(string) when is_binary(string) do
    string = String.trim_trailing(string, "/")
    split_string = String.split(string, "/")

    with {:ok, ""} <- Enum.fetch(split_string, 0) do
      string_to_bytes(Enum.slice(split_string, 1..-1), <<>>)
    end
  end

  defp string_to_bytes(string_split, bytes) when string_split == [] and is_binary(bytes) do
    {:ok, bytes}
  end

  defp string_to_bytes(string_split, bytes) when is_list(string_split) and is_binary(bytes) do
    with {:ok, protocol_name} <- Enum.fetch(string_split, 0),
         {:ok, protocol} <- Map.fetch(Prot.protocols_by_name(), protocol_name),
         {:ok, protocol_bytes} <- protocol.transcoder.string_to_bytes.(Enum.at(string_split, 1)) do
      bytes = bytes <> protocol.vcode <> protocol_bytes
      string_to_bytes(Enum.slice(string_split, 2..-1), bytes)
    else
      _ ->
        {:error, "Invalid Multiaddr string"}
    end
  end

  def bytes_to_string(bytes) when is_binary(bytes) do
    bytes_to_string(bytes, "")
  end

  defp bytes_to_string(bytes, string) when bytes == <<>> and is_binary(string) do
    {:ok, string}
  end

  defp bytes_to_string(bytes, string) when is_binary(bytes) and is_binary(string) do
    case read_protocol(bytes) do
      {:ok, next_index, {protocol, value}} ->
        string = string <> "/" <> protocol.name <> "/" <> value
        bytes_to_string(split_binary(bytes, next_index..-1), string)

      _ ->
        {:error, "Invalid Multiaddr"}
    end
  end

  def find_protocol_by_value(bytes, %Prot{} = protocol, value)
      when is_binary(bytes) and is_binary(value) do
    with {:ok, index, protocol_value} <- find_protocol(bytes, protocol) do
      if value == protocol_value do
        {:ok, index, protocol_value}
      else
        {:ok, {value_index, _code}} = read_varint(bytes)
        bytes = split_binary(bytes, (value_index + div(protocol.size, 8))..0)
        find_protocol_by_value(bytes, protocol, value)
      end
    end
  end

  def find_protocol(bytes, %Prot{} = protocol) when is_binary(bytes) do
    find_protocol(bytes, protocol.code, 0)
  end

  defp find_protocol(bytes, code, index)
       when is_binary(bytes) and is_integer(code) and is_integer(index) do
    with {:ok, next_index, {protocol, value}} <- read_protocol(bytes) do
      if protocol.code == code do
        {:ok, index, value}
      else
        find_protocol(split_binary(bytes, next_index..-1), code, index + next_index)
      end
    end
  end

  defp read_protocol(bytes) when bytes == <<>> do
    {:error, "End of bytes"}
  end

  defp read_protocol(bytes) when is_binary(bytes) do
    {:ok, {value_index, code}} = read_varint(bytes)
    bytes = split_binary(bytes, value_index..-1)

    with {:ok, protocol} <- Map.fetch(Prot.protocols_by_code(), code),
         true <- byte_size(bytes) >= div(protocol.size, 8),
         {:ok, protocol_value} <-
           protocol.transcoder.bytes_to_string.(
             split_binary(bytes, 0..(div(protocol.size, 8) - 1))
           ) do
      {:ok, value_index + div(protocol.size, 8), {protocol, protocol_value}}
    else
      _ ->
        {:error, "Invalid Multiaddr"}
    end
  end
end

defmodule Multiaddr.Codec do
  import Multiaddr.Varint
  import Multiaddr.Utils
  alias Multiaddr.Protocol, as: Prot

  defp validate_bytes(bytes, protocols_list) when bytes == "" do
    {:ok, protocols_list}
  end

  defp validate_bytes(bytes, protocols_list) when is_binary(bytes) do
    {:ok, {i, code}} = read_varint(bytes)
    bytes = split_binary(bytes, i..-1)

    with {:ok, protocol} <- Map.fetch(Prot.protocols_by_code(), code),
         true <- byte_size(bytes) >= div(protocol.size, 8) do
      validate_bytes(split_binary(bytes, div(protocol.size, 8)..-1), protocols_list ++ [protocol])
    else
      _ ->
        {:error, "Invalid Multiaddr"}
    end
  end

  def validate_bytes(bytes) when is_binary(bytes) do
    validate_bytes(bytes, [])
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

  def find_protocol_value(bytes, code) when is_binary(bytes) and is_integer(code) do
    with {:ok, next_index, {protocol, value}} <- read_protocol(bytes) do
      if protocol.code == code do
        {:ok, value}
      else
        find_protocol_value(split_binary(bytes, next_index..-1), code)
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

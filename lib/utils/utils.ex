defmodule Multiaddr.Utils do
  alias Multiaddr.Protocol
  alias Multiaddr.Utils.Varint

  def split_binary(b, index_range) when is_binary(b) do
    b
    |> :binary.bin_to_list()
    |> Enum.slice(index_range)
    |> :binary.list_to_bin()
  end

  def size_for_protocol(%Protocol{size: p_size, name: name} = _protocol, bytes)
      when p_size == :prefixed_var_size do
    if {:ok, {index, size}} = Varint.read_varint(bytes) do
      {:ok, {index, size}}
    else
      {:error, {:invalid_bytes, "Invalid #{name} bytes "}}
    end
  end

  def size_for_protocol(%Protocol{size: p_size} = _protocol, _bytes)
      when is_integer(p_size) and p_size >= 0 do
    {:ok, {0, div(p_size, 8)}}
  end

  def i2p_encode64(bytes) when is_binary(bytes) do
    encoded_string =
      bytes
      |> Base.encode64(padding: false)
      |> String.replace("+", "-")
      |> String.replace("/", "~")

    {:ok, encoded_string}
  end

  def i2p_decode64(i2p_string) when is_binary(i2p_string) do
    with true <- String.valid?(i2p_string),
         string <- i2p_string |> String.replace("-", "+") |> String.replace("~", "/"),
         {:ok, encoded_bytes} <- Base.decode64(string, padding: false),
         true <- encoded_bytes != :error do
      {:ok, encoded_bytes}
    else
      _error -> {:error, {:invalid_string, "Invalid i2p encoded string #{i2p_string}"}}
    end
  end
end

defmodule Multiaddr.Utils do
  alias Multiaddr.Protocol
  alias Multiaddr.Utils.Varint

  def split_binary(b, index_range) when is_binary(b) do
    b
    |> :binary.bin_to_list()
    |> Enum.slice(index_range)
    |> :binary.list_to_bin()
  end

  def size_for_protocol(%Protocol{size: p_size} = _protocol, bytes)
      when p_size == :prefixed_var_size do
    if {:ok, {index, size}} = Varint.read_varint(bytes) do
      {:ok, {index, size}}
    else
      {:error, "Invalid Varint"}
    end
  end

  def size_for_protocol(%Protocol{size: p_size} = _protocol, _bytes)
      when is_integer(p_size) and p_size >= 0 do
    {:ok, {0, div(p_size, 8)}}
  end
end

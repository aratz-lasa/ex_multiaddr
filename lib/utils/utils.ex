defmodule Multiaddr.Utils do
  def split_binary(b, index_range) when is_binary(b) do
    b
    |> :binary.bin_to_list()
    |> Enum.slice(index_range)
    |> :binary.list_to_bin()
  end
end

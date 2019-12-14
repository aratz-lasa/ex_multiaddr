defmodule Multiaddr do
  @moduledoc """
  This is the Multiaddr public API module.
  """

  import Multiaddr.Utils
  alias Multiaddr.Protocol
  alias Multiaddr.Codec
  alias Multiaddr.Error

  defstruct [:bytes]

  @type protocol_name() :: String.t()
  @type protocol_value() :: String.t()
  @type protocol_code() :: integer()

  @doc """
  Parses and validates an input string, returning a `Multiaddr`.

  Returns: `{:ok, maddr}`

  ## Examples
  iex> {:ok, _maddr} = Multiaddr.new_multiaddr_from_string("/ip4/127.0.0.1")
  {:ok, %Multiaddr{bytes: <<4, 127, 0, 0, 1>>}}
  """
  @spec new_multiaddr_from_string(String.t()) :: %Multiaddr{}
  def new_multiaddr_from_string(string) when is_binary(string) do
    case Codec.string_to_bytes(string) do
      {:ok, bytes} -> {:ok, %Multiaddr{bytes: bytes}}
      error -> error
    end
  end

  @doc """
  Initializes a Multiaddr from a byte representation. It validates it as an input string.

  Returns: `{:ok, maddr}`

  ## Examples
  iex> {:ok, _maddr} = Multiaddr.new_multiaddr_from_bytes(<<4, 127, 0, 0, 1>>)
  {:ok, %Multiaddr{bytes: <<4, 127, 0, 0, 1>>}}
  """
  @spec new_multiaddr_from_bytes(binary()) :: %Multiaddr{}
  def new_multiaddr_from_bytes(bytes) when is_binary(bytes) do
    case Codec.validate_bytes(bytes) do
      {:ok, _bytes} -> {:ok, %Multiaddr{bytes: bytes}}
      error -> error
    end
  end

  @doc """
  Tests whether two multiaddrs are equal.

  Returns: `true` or `false`

  ## Examples
  iex> {:ok, maddr} = Multiaddr.new_multiaddr_from_string("/ip4/127.0.0.1")
  {:ok, %Multiaddr{bytes: <<4, 127, 0, 0, 1>>}}
  iex> true = Multiaddr.equal(maddr, maddr)
  true
  """
  @spec equal(%Multiaddr{}, %Multiaddr{}) :: boolean()
  def equal(%Multiaddr{} = maddr1, %Multiaddr{} = maddr2) do
    maddr1 == maddr2
  end

  @doc """
  Returns the byte representation of this Multiaddr.

  Returns: `maddr_bytes`

  ## Examples
  iex> {:ok, maddr} = Multiaddr.new_multiaddr_from_string("/ip4/127.0.0.1")
  {:ok, %Multiaddr{bytes: <<4, 127, 0, 0, 1>>}}
  iex> Multiaddr.bytes(maddr)
  <<4, 127, 0, 0, 1>>
  """
  @spec bytes(%Multiaddr{}) :: binary()
  def bytes(%Multiaddr{bytes: maddr_bytes} = _maddr) do
    maddr_bytes
  end

  @doc """
  Returns the string representation of this Multiaddr.

  Returns: `maddr_string`

  ## Examples
  iex> {:ok, maddr} = Multiaddr.new_multiaddr_from_string("/ip4/127.0.0.1")
  {:ok, %Multiaddr{bytes: <<4, 127, 0, 0, 1>>}}
  iex> Multiaddr.string(maddr)
  "/ip4/127.0.0.1"
  """
  @spec string(%Multiaddr{}) :: String.t()
  def string(%Multiaddr{bytes: maddr_bytes} = _maddr) do
    case Codec.bytes_to_string(maddr_bytes) do
      {:ok, string} -> string
      {:error, reason} -> raise Multiaddr.Error, reason: reason
    end
  end

  @doc """
  Returns the list of protocols this Multiaddr has.

  Returns: `protocols_list`

  ## Examples
  iex> {:ok, maddr} = Multiaddr.new_multiaddr_from_string("/ip4/127.0.0.1")
  {:ok, %Multiaddr{bytes: <<4, 127, 0, 0, 1>>}}
  iex> [ip4_protocol] = Multiaddr.protocols(maddr)
  iex> ip4_protocol.name == "ip4"
  true

  """
  @spec protocols(%Multiaddr{}) :: list(%Protocol{})
  def protocols(%Multiaddr{bytes: maddr_bytes} = _maddr) do
    case Codec.list_protocols(maddr_bytes) do
      {:ok, maddr_protocols} -> maddr_protocols
      {:error, reason} -> raise Multiaddr.Error, reason: reason
    end
  end

  @doc """
  It wraps a given Multiaddr, returning the resulting joined Multiaddr.

  Returns: `{:ok, maddr}`

  ## Examples
  iex> {:ok, maddr_1} = Multiaddr.new_multiaddr_from_string("/ip4/127.0.0.1")
  {:ok, %Multiaddr{bytes: <<4, 127, 0, 0, 1>>}}
  iex> {:ok, maddr_2} = Multiaddr.new_multiaddr_from_string("/tcp/80")
  {:ok, %Multiaddr{bytes: <<6, 0, 80>>}}
  iex> {:ok, _maddr} = Multiaddr.encapsulate(maddr_1, maddr_2)
  {:ok, %Multiaddr{bytes: <<4, 127, 0, 0, 1, 6, 0, 80>>}}
  """
  @spec encapsulate(%Multiaddr{}, %Multiaddr{}) :: %Multiaddr{}
  def encapsulate(
        %Multiaddr{bytes: maddr_1_bytes} = maddr_1,
        %Multiaddr{bytes: maddr_2_bytes} = _maddr_2
      ) do
    with false <- contains_path_protocol?(maddr_1),
         {:ok, _bytes} <- Codec.validate_bytes(maddr_1_bytes),
         {:ok, _bytes} <- Codec.validate_bytes(maddr_2_bytes) do
      {:ok, %Multiaddr{bytes: maddr_1_bytes <> maddr_2_bytes}}
    else
      true -> {:error, {:invalid_order, "Path must be last protocol"}}
      {:error, reason} -> raise Multiaddr.Error, reason: reason
    end
  end

  defp contains_path_protocol?(%Multiaddr{} = maddr) do
    maddr
    |> protocols()
    |> Enum.any?(fn p -> p.path end)
  end

  @doc """
  It unwraps Multiaddr up until the given Multiaddr is found.

  Returns: `{:ok, maddr}`

  ## Examples
  iex> {:ok, maddr} = Multiaddr.new_multiaddr_from_string("/ip4/127.0.0.1/tcp/80")
  {:ok, %Multiaddr{bytes: <<4, 127, 0, 0, 1, 6, 0, 80>>}}
  iex> {:ok, maddr_2} = Multiaddr.new_multiaddr_from_string("/tcp/80")
  {:ok, %Multiaddr{bytes: <<6, 0, 80>>}}
  iex> {:ok, maddr_1} = Multiaddr.decapsulate(maddr, maddr_2)
  {:ok, %Multiaddr{bytes: <<4, 127, 0, 0, 1>>}}
  iex> Multiaddr.string(maddr_1)
  "/ip4/127.0.0.1"
  """
  @spec decapsulate(%Multiaddr{}, %Multiaddr{}) :: %Multiaddr{}
  def decapsulate(
        %Multiaddr{bytes: maddr_1_bytes} = _maddr_1,
        %Multiaddr{bytes: maddr_2_bytes} = _maddr_2
      ) do
    with {:ok, index} = Codec.find_sub_multiaddr(maddr_1_bytes, maddr_2_bytes) do
      {:ok, %Multiaddr{bytes: split_binary(maddr_1_bytes, 0..(index - 1))}}
    end
  end

  @doc """
  It returns the value in string representation, for a given protocol. If there are more than one, only the first is returned.

  Returns: `{:ok, value}`

  ## Examples
  iex> {:ok, maddr} = Multiaddr.new_multiaddr_from_string("/ip4/127.0.0.1/tcp/80")
  {:ok, %Multiaddr{bytes: <<4, 127, 0, 0, 1, 6, 0, 80>>}}
  iex> Multiaddr.value_for_protocol(maddr, "tcp")
  {:ok, "80"}
  """
  @spec value_for_protocol(%Multiaddr{}, protocol_name()) :: protocol_value()
  def value_for_protocol(%Multiaddr{bytes: maddr_bytes} = _maddr, name) when is_binary(name) do
    with {:ok, protocol} <- Map.fetch(Protocol.protocols_by_name(), name),
         {:ok, _index, value} <- Codec.find_protocol(maddr_bytes, protocol) do
      {:ok, value}
    else
      :error -> {:error, {:invalid_protocol_name, name}}
      error -> error
    end
  end

  @spec value_for_protocol(%Multiaddr{}, protocol_code()) :: protocol_value()
  def value_for_protocol(%Multiaddr{} = maddr, code) when is_integer(code) do
    with {:ok, protocol} <- Map.fetch(Protocol.protocols_by_code(), code),
         {:ok, _index, value} <- Codec.find_protocol(maddr.bytes, protocol) do
      {:ok, value}
    else
      :error -> {:error, {:invalid_protocol_code, code}}
      error -> error
    end
  end

  def format_error(error), do: Error.format_error(error)
end

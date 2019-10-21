defmodule Multiaddr do
  defstruct [:string]

  def equal(%Multiaddr{} = maddr1, %Multiaddr{} = maddr2) do
    maddr1 == maddr2
  end

  def bytes(%Multiaddr{} = maddr) do
  end

  def string(%Multiaddr{} = maddr) do
    maddr.string
  end

  def protocols(%Multiaddr{} = maddr) do
  end

  def encapsulate(%Multiaddr{} = maddr) do
  end

  def decapsulate(%Multiaddr{} = maddr) do
  end

  def value_for_protocol(%Multiaddr{} = maddr, code) when is_integer(code) do
  end
end

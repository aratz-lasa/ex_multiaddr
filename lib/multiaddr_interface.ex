defmodule Multiaddr.Interface do
  @moduledoc """
  Module for showing functions implemented by Multiaddr.
  It is just for reading. Not implemented as behaviour because,
  it is not meant to be implemented by a process for callbacks. 
  """
  def equal(%Multiaddr{} = maddr1, %Multiaddr{} = maddr2) do
  end

  def bytes(%Multiaddr{} = maddr) do
  end

  def string(%Multiaddr{} = maddr) do
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

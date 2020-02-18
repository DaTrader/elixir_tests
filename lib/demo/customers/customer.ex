defmodule Demo.Customers.Customer do
  @moduledoc """
  Sample module for LiveView testing purposes
  """

  alias Demo.Customers.Customer

  @type t() :: %Customer{
                 id: integer(),
                 name: String.t() | nil,
                 address: String.t() | nil
               }
  defstruct(
    id: nil,
    name: nil,
    address: nil
  )

  @spec new( integer(), String.t(), String.t()) :: t()
  def new( id, name, address) do
    %Customer{
      id: id,
      name: name,
      address: address
    }
  end

  @spec update( t(), %{ atom() => String.t()}) :: t()
  def update( %Customer{} = customer, %{} = changes) do
    customer
    |> Map.from_struct()
    |> Map.merge( Map.take( changes, [ :name, :address]))
    |> Map.put( :__struct__, __MODULE__)
  end
end

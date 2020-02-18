defmodule Demo.Customers do
  alias Demo.Customers.Customer


  @spec list_all() :: [ Customer.t()]
  def list_all() do
    [
      Customer.new( 0, "Alice", "New York"),
      Customer.new( 1, "Bob",  "Los Angeles"),
      Customer.new( 2, "Carol", "Chicago")
    ];
  end


  @spec get_customer( [ Customer.t()], integer()) :: Customer.t()
  def get_customer( customers, id),
      do: Enum.find( customers, nil, fn %Customer{ id: cid} -> cid == id end)


  @spec update_customer( [ Customer.t()], integer(), %{ atom() => String.t()})
        :: { :ok, [ Customer.t()]} | { :error, :not_found | :no_change}
  def update_customer( customers, id, changes),
      do: update_at_index( customers, customer_index( customers, id), changes)

  defp update_at_index( _, nil, _),
       do: { :error, :not_found}

  defp update_at_index( customers, x, changes) do
    case List.update_at( customers, x, &Customer.update( &1, changes)) do
      ^customers -> { :error, :no_change}
      new_customers -> { :ok, new_customers}
    end
  end


  @spec insert_before( [ Customer.t()], integer()) :: { :ok, { [ Customer.t()], integer()}} | { :error, :not_found}
  def insert_before( customers, id),
      do: insert_at_index( customers, customer_index( customers, id))

  defp insert_at_index( _, nil),
       do: { :error, :not_found}

  defp insert_at_index( customers, x) do
    id = length( customers)
    customers = List.insert_at( customers, x, Customer.new( id, "", ""))
    { :ok, { customers, id}}
  end


  @spec move_customer( [ Customer.t()], integer(), integer()) :: { :ok, [ Customer.t()]}
  def move_customer( customers, src_id, dst_id) do
    dst_index = customer_index( customers, dst_id)
    src_index = customer_index( customers, src_id)
    customers = list_move( customers, dst_index, src_index)
    { :ok, customers}
  end


  @spec customer_index( [ Customer.t()], integer()) :: non_neg_integer() | nil
  defp customer_index( customers, id),
       do: Enum.find_index( customers, fn %Customer{ id: cid} -> cid === id end)


  defguard is_non_neg_integer( term) when is_integer( term) and term >= 0

  @spec list_move( [ any()], dst_x :: non_neg_integer(), src_x :: non_neg_integer()) :: [ any()]
  defp list_move( list, dst, src) when is_list( list) and is_non_neg_integer( dst) and is_non_neg_integer( src) do
    src != dst &&
      case List.pop_at( list, src) do
        { nil, _} -> list
        { e, rest} -> List.insert_at( rest, dst, e)
      end
    || list
  end
end

defmodule DemoWeb.CustomersLive do
  use Phoenix.LiveView
  alias Demo.Customers

  def mount( _params, _session, socket) do
    socket =
      socket
      |> assign_customers( Customers.list_all())
      |> assign_change_failed( false)
      |> assign_event_msg( nil)
    { :ok, socket, temporary_assigns: [ event_msg: nil, change_failed: false]}
  end


  def render( assigns),
      do: Phoenix.View.render( DemoWeb.CustomersView, "customers.html", assigns)


  # delegate all body keyup pattern event to their handlers
  def handle_event( "mdl_keyup:" <> id_str,
        %{ "key" => "Insert", "metaKey" => false, "altKey" => false, "shiftKey" => false}, socket) do
    %{ assigns: %{ customers: customers}} = socket
    socket =
      with { :ok, { customers, new_id}} <- Customers.insert_before( customers, customer_id( id_str)) do
        socket
        |> assign_customers( customers)
        |> assign_event_msg( { :item_inserted, new_id})
      else
        { :error, _} -> socket
      end
    { :noreply, socket}
  end

  # other keyup events
  def handle_event( "mdl_keyup:" <> _, _, socket),
      do: { :noreply, socket}


  # JS row drag & drop event
  def handle_event( "move_row", %{ "drag_row" => "customer_" <> drag, "drop_row" => "customer_" <> drop }, socket) do
    %{ assigns: %{ customers: customers}} = socket
    { :ok, customers} = Customers.move_customer( customers, customer_id( drag), customer_id( drop))
    { :noreply, assign_customers( socket, customers)}
  end


  # customer model changes (testing purposes)
  def handle_event( "mdl_change", %{ "id" => id_str, "data" => "customer." <> attr_str, "value" => value}, socket) do
    %{ assigns: %{ customers: customers}} = socket
    socket =
      with { :ok, customers} <-
             Customers.update_customer( customers, customer_id( id_str), %{ customer_attr( attr_str) => value}) do
        assign_customers( socket, customers)
      else
        { :error, _} -> assign_change_failed( socket, true)
      end
    { :noreply, socket}
  end


  # generic event handler
  def handle_event( event, inputs, socket) do
    IO.puts( "Event: #{ inspect( event)}")
    IO.puts( "Inputs: #{ inspect( inputs)}}")
    { :noreply, socket}
  end


  defp customer_id( id_str),
       do: String.to_integer( id_str)

  defp customer_attr( attr_str),
       do: %{ "name" => :name, "address" => :address}[ attr_str]


  defp assign_change_failed( socket, failed?),
       do: assign( socket, :change_failed, failed?)

  defp assign_customers( socket, customers),
       do: assign( socket, :customers, customers)

  defp assign_event_msg( socket, event_msg),
       do: assign( socket, :event_msg, event_msg)

end

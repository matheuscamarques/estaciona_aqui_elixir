defmodule EstacionaAquiWeb.PageController do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
     <style>
       .flex{
         display: flex
       }

       .flex-wrap{
         flex-wrap: wrap
       }

       .box{
         width: 200px;
         height: 150px;
       }

       .bg-red{
         background: red;
       }

       .bg-green{
         background: green;
       }

       .p-1{
         padding: 1em;
       }

       .m-1{
         margin: 1.2em;
       }

       .bg-gray {
         background: gray;
       }
     </style>
     Current Spaces: <%= Enum.count(@free_spaces) %>
     <br/>
     <.render_spaces free_spaces={@free_spaces} />
    """
  end

  def render_spaces(assigns) do
    ~H"""
     <div 
      class="flex flex-wrap"
     >
        <%= for space <- @free_spaces do %>
            <.render_space space={space} />
        <% end %>
      </div>
    """
  end

  def render_space(%{space: sensor}) do
    handle_space(sensor)
  end

  def handle_space({{:badrpc, _}, state} = assigns) do
    ~H"""
     <div
        class="box bg-gray m-1"
     >
        <%=  state  %> 
     </div>
    """
  end


  def handle_space({false, state} = assigns) do
    ~H"""
     <div
        class="box bg-red m-1"
        phx-click="call_sensor"
        phx-value-id={state}
     >
        <%=  state  %> 
     </div>
    """
  end

  def handle_space({true, state} = assigns) do
    ~H"""
     <div
        class="box bg-green m-1"
        phx-click="call_sensor"
        phx-value-id={state}
     >
        <%= state  %> 
     </div>
    """
  end

  def mount(_params, _, socket) do
    Phoenix.PubSub.subscribe(EstacionaAqui.PubSub,"sensors")
    socket = assign(socket, :free_spaces, Sensors.get())
    {:ok, socket}
  end

  def handle_event("call_sensor", %{"id" => id}, socket) do
    [finded] = Sensors.get() 
                |> Enum.filter(fn {_, sensor_id} ->"#{sensor_id}" == "#{id}" end)

    {_ , sensor} = finded
    Sensor.update(sensor)
    Phoenix.PubSub.broadcast(EstacionaAqui.PubSub, "sensors", :reload)

    send(self(), :reload)
    {:noreply, socket}
  end

  def handle_info(:reload, socket) do
    socket = assign(socket, :free_spaces, Sensors.get())
    {:noreply, socket}
  end
end

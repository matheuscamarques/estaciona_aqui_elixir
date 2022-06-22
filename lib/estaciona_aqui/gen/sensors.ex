defmodule Sensor do

  def get(sname) do
    :rpc.call(sname, Sensor, :get, [])
  end

  def update(sname) do
    :rpc.call(sname, Sensor, :update, [])
  end
  
end


defmodule Sensors do
  use GenServer

  def init(stack) do
    {:ok, stack}
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, MapSet.new(), name: __MODULE__)
  end

  def handle_call(:get_all, _from, state) do
    reply = Enum.map(state , fn sensor -> {Sensor.get(sensor) , sensor} end)
    {:reply, reply, state}
  end

  def handle_call({:add_novo_sensor, sname}, _from, state) do
    newState = MapSet.put(state,sname)
    {:reply, newState, newState}
  end

  def handle_call({:remove, sname}, _from, state) do
    newState = MapSet.delete(state,sname)
    {:reply, newState, newState}
  end

  def get() do
    GenServer.call(Sensors, :get_all)
  end

  def set(sname) do
    IO.puts("Chegou algo!")
    Phoenix.PubSub.broadcast(EstacionaAqui.PubSub, "sensors", :reload)
    GenServer.call(Sensors, {:add_novo_sensor, sname})
  end

  def remove(sname) do
    GenServer.call(Sensors, {:remove, sname})
  end
end

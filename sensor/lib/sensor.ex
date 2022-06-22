defmodule Sensor do 
  use GenServer
  
  ## SERVER
  def init(_opts) do
    {:ok, true}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:update, _from, state) do
    {:reply, !state, !state}
  end




  ## CLIENT 
  def start_link(_opts) do
     IO.puts("Try connect principal host")
     sname = node(self())
     :rpc.call(:"principal@web-engenharia", Sensors , :set , [sname])
     GenServer.start_link(Sensor,false , name: Sensor) 
  end

  def get() do 
    GenServer.call(Sensor, :get)
  end

  def update() do
    GenServer.call(Sensor, :update)
  end
end
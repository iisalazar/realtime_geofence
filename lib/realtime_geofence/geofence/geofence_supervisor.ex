defmodule GeofenceSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec create_geofence(any(), any(), any(), any()) ::
          :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  def create_geofence(id, type, value, webhook) do
    DynamicSupervisor.start_child(__MODULE__, {Geofence, {id, type, value, webhook}})
  end

  def kill_geofence(geofence_id) do
    pid = RegistryHelper.get_pid(geofence_id)
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end
end

defmodule RegistryHelper do
  @behaviour RegistryHelperBehavior

  @impl true
  def create_key(geofence_id), do: {:via, Registry, {Geofence.Registry, geofence_id}}

  @spec register(String.t()) :: {:ok, pid} | {:error, {:already_registered, pid}}
  def register(geofence_id), do: Registry.register(Geofence.Registry, create_key(geofence_id), [])

  @impl RegistryHelperBehavior
  def get_pid(geofence_id) do
    [{pid, _}] = Registry.lookup(Geofence.Registry, geofence_id)
    pid
  end

  @impl RegistryHelperBehavior
  def create_key(collection_name, :collection),
    do: {:via, Registry, {Collection.Registry, collection_name}}

  def register(collection_name, :collection),
    do: Registry.register(Collection.Registry, create_key(collection_name), [])

  @impl RegistryHelperBehavior
  def get_pid(collection_name, :collection) do
    [{pid, _}] = Registry.lookup(Collection.Registry, collection_name)
    pid
  end
end

defmodule CollectionSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_collection(collection_name) do
    DynamicSupervisor.start_child(__MODULE__, {Collection, {collection_name}})
  end

  def kill_collection(collection_name) do
    pid = RegistryHelper.get_pid(collection_name, :collection)
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end
end

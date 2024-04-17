defmodule Collection do
  use GenServer

  defstruct [:collection_name, :points, :geofence_ids]

  def start_link({collection_name}) do
    GenServer.start_link(__MODULE__, {collection_name},
      name: registry_helper_impl().create_key(collection_name, :collection)
    )
  end

  def init({collection_name}) do
    {:ok, %Collection{collection_name: collection_name, points: [], geofence_ids: []}}
  end

  def get_state(collection_name) do
    GenServer.call(registry_helper_impl().get_pid(collection_name, :collection), :get_state)
  end

  def set_points(collection_name, points) do
    GenServer.cast(
      registry_helper_impl().get_pid(collection_name, :collection),
      {:set_points, points}
    )
  end

  def set_point(collection_name, point) do
    GenServer.cast(
      registry_helper_impl().get_pid(collection_name, :collection),
      {:set_point, point}
    )
  end

  def add_geofence(collection_name, geofence_id) do
    GenServer.call(
      registry_helper_impl().get_pid(collection_name, :collection),
      {:add_geofence, geofence_id}
    )
  end

  def remove_geofence(collection_name, geofence_id) do
    GenServer.call(
      registry_helper_impl().get_pid(collection_name, :collection),
      {:remove_geofence, geofence_id}
    )
  end

  def handle_call(:get_state, _from, state) do
    {:reply, {:ok, {state.collection_name, state.points, state.geofence_ids}}, state}
  end

  def handle_call({:add_geofence, geofence_id}, _from, state) do
    case Enum.find(state.geofence_ids, fn id -> id == geofence_id end) do
      nil -> {:reply, :ok, %{state | geofence_ids: [geofence_id | state.geofence_ids]}}
      _ -> {:reply, :ok, state}
    end
  end

  def handle_call({:remove_geofence, geofence_id}, _from, state) do
    case Enum.find(state.geofence_ids, fn id -> id == geofence_id end) do
      nil ->
        {:error, "Geofence not found"}

      _ ->
        {:reply, {:ok},
         %{state | geofence_ids: Enum.filter(state.geofence_ids, fn id -> id != geofence_id end)}}
    end
  end

  def handle_cast({:set_point, point}, state) do
    # check if the point is in the points state
    case Enum.find(state.points, fn p -> p.id == point.id end) do
      nil ->
        {:noreply, %{state | points: add_to_points(state.points, point)}}

      _ ->
        publish_to_geofences(state.geofence_ids, point)
        {:noreply, %{state | points: update_point(state.points, point)}}
    end
  end

  def update_point(points, point) do
    Enum.map(points, fn p ->
      if p.id == point.id do
        point
      else
        p
      end
    end)
  end

  def add_to_points(points, point) do
    [point | points]
  end

  defp geofence_impl() do
    Application.get_env(:realtime_geofence, :geofence_impl, Geofence)
  end

  defp registry_helper_impl() do
    Application.get_env(:realtime_geofence, :registry_helper_impl, RegistryHelper)
  end

  def publish_to_geofences(geofence_ids, point) do
    Enum.each(geofence_ids, fn geofence_id ->
      geofence_impl().handle_point(geofence_id, point)
    end)
  end
end

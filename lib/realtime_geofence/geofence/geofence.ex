defmodule Geofence do
  @behaviour GeofenceBehavior

  use GenServer

  defstruct [:id, :type, :value]

  def start_link({id, type, value}) do
    Geofences.Types.is_valid_type(type) || raise ArgumentError, "Invalid geofence type"
    {_, valid_type} = Geofences.Types.get_type(type)

    Geofences.Types.is_valid_value(valid_type, value) ||
      raise ArgumentError, "Invalid geofence value"

    GenServer.start_link(__MODULE__, {id, valid_type, value},
      name: registry_helper_impl().create_key(id)
    )
  end

  @impl true
  def init({id, type, value}) do
    {:ok, %Geofence{id: id, type: type, value: value}}
  end

  @spec get_state(binary()) :: any()
  def get_state(geofence_id) do
    GenServer.call(registry_helper_impl().get_pid(geofence_id), :get_state)
  end

  @impl GeofenceBehavior
  def handle_point(geofence_id, point) do
    GenServer.cast(registry_helper_impl().get_pid(geofence_id), {:handle_point, point})
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, {:ok, {state.id, state.type, state.value}}, state}
  end

  defp raycasting_impl() do
    Application.get_env(:realtime_geofence, :raycasting_impl, Raycasting)
  end

  defp registry_helper_impl() do
    Application.get_env(:realtime_geofence, :registry_helper_impl, RegistryHelper)
  end

  @impl true
  def handle_cast({:handle_point, point}, state) do
    is_inside = raycasting_impl().is_inside(point, state.value)
    IO.inspect(is_inside)
    {:noreply, state}
  end
end

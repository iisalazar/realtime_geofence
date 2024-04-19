defmodule Geofence do
  @behaviour GeofenceBehavior

  use GenServer

  defstruct [:id, :type, :value, :webhook]

  def start_link({id, type, value, webhook}) do
    Geofences.Types.is_valid_type(type) || raise ArgumentError, "Invalid geofence type"
    {_, valid_type} = Geofences.Types.get_type(type)

    Geofences.Types.is_valid_value(valid_type, value) ||
      raise ArgumentError, "Invalid geofence value"

    is_valid_webhook_url(webhook) ||
      raise ArgumentError, "Invalid webhook url"

    GenServer.start_link(__MODULE__, {id, valid_type, value, webhook},
      name: registry_helper_impl().create_key(id)
    )
  end

  @spec is_valid_webhook_url(String.t()) :: boolean()
  def is_valid_webhook_url(url) do
    case URI.parse(url) do
      %URI{scheme: nil} -> false
      %URI{host: nil} -> false
      _ -> true
    end
  end

  @impl true
  def init({id, type, value, webhook}) do
    {:ok, %Geofence{id: id, type: type, value: value, webhook: webhook}}
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

  @callback http_client_service_impl() :: HttpClientServiceBehavior
  def http_client_service_impl() do
    Application.get_env(:realtime_geofence, :http_client_service_impl, HttpClientService)
  end

  @impl true
  def handle_cast({:handle_point, point}, state) do
    is_inside = raycasting_impl().is_inside(point, state.value)
    IO.inspect(is_inside)

    case is_inside do
      true ->
        http_client_service_impl().send(:post, state.webhook, %GeofenceEvent{
          point_identifier: point.id,
          identifier_type: "point.id",
          detect: "inside"
        })

      _ ->
        http_client_service_impl().send(:post, state.webhook, %GeofenceEvent{
          point_identifier: point.id,
          identifier_type: "point.id",
          detect: "outside"
        })
    end

    {:noreply, state}
  end
end

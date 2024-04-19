Mox.defmock(RaycastingBehaviorMock, for: RaycastingBehavior)
Mox.defmock(GeofenceBehaviorMock, for: GeofenceBehavior)
Mox.defmock(RegistryHelperBehaviorMock, for: RegistryHelperBehavior)
Mox.defmock(HttpClientServiceBehaviorMock, for: HttpClientServiceBehavior)

Application.put_env(:realtime_geofence, :raycasting_impl, RaycastingBehaviorMock)
Application.put_env(:realtime_geofence, :geofence_impl, GeofenceBehaviorMock)
Application.put_env(:realtime_geofence, :registry_helper_impl, RegistryHelperBehaviorMock)
Application.put_env(:realtime_geofence, :http_client_service_impl, HttpClientServiceBehaviorMock)

ExUnit.start()

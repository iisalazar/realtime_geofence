Mox.defmock(RaycastingBehaviorMock, for: RaycastingBehavior)
Mox.defmock(GeofenceBehaviorMock, for: GeofenceBehavior)
Mox.defmock(RegistryHelperBehaviorMock, for: RegistryHelperBehavior)

Application.put_env(:realtime_geofence, :raycasting_impl, RaycastingBehaviorMock)
Application.put_env(:realtime_geofence, :geofence_impl, GeofenceBehaviorMock)

Application.put_env(:realtime_geofence, :registry_helper_impl, RegistryHelperBehaviorMock)

ExUnit.start()

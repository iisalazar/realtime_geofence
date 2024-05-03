defmodule RealtimeGeofence.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Supervisor.child_spec({Registry, [keys: :unique, name: Geofence.Registry]},
        id: :geofence_registry
      ),
      Supervisor.child_spec({Registry, [keys: :unique, name: Collection.Registry]},
        id: :collection_registry
      ),
      Supervisor.child_spec({GeofenceSupervisor, []}, id: GeofenceSupervisor),
      Supervisor.child_spec({CollectionSupervisor, []}, id: CollectionSupervisor),
      {Plug.Cowboy, scheme: :http, plug: App.Router, options: [port: 3000]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RealtimeGeofence.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule App.Router do
  use Plug.Router

  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "PONG")
  end

  post "/geofences" do
    id = conn.body_params["id"]
    type = conn.body_params["type"]
    value = conn.body_params["value"]
    webhook = conn.body_params["webhook"]

    GeofenceSupervisor.create_geofence(id, type, value, webhook)

    send_resp(conn, 201, Poison.encode!(%{message: "Geofence created"}))
  end

  post "/collections" do
    collection_name = conn.body_params["name"]

    case CollectionSupervisor.create_collection(collection_name) do
      {:ok, _} ->
        send_resp(conn, 201, Poison.encode!(%{message: "Collection created"}))

      {:error, {:already_started, _}} ->
        send_resp(conn, 400, Poison.encode!(%{error: "Collection already exists"}))

      _ ->
        send_resp(conn, 500, Poison.encode!(%{error: "internal server error"}))
    end
  end

  post "/collections/:collection_name/geofences" do
    # adds a goefence id to a collection
    collection_name = conn.params["collection_name"]
    geofence_id = conn.body_params["geofence_id"]
    Collection.add_geofence(collection_name, geofence_id)

    send_resp(conn, 201, Poison.encode!(%{message: "Geofence added to collection"}))
  end

  post "/collections/:collection_name/points" do
    # adds a point to a collection
    collection_name = conn.params["collection_name"]
    id = conn.body_params["id"]
    x = conn.body_params["x"]
    y = conn.body_params["y"]
    point = %Point{id: id, x: x, y: y}
    Collection.set_point(collection_name, point)

    send_resp(conn, 201, Poison.encode!(%{message: "Point added to collection"}))
  end
end

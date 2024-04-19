defmodule GeofenceTest do
  use ExUnit.Case

  import Mox

  test "start_link when type is invalid raise ArgumentError" do
    assert_raise ArgumentError, "Invalid geofence type", fn ->
      Geofence.start_link({1, "invalid type", 1, ""})
    end
  end

  test "start_link when value is not a list of Point raise ArgumentError" do
    assert_raise ArgumentError, "Invalid geofence value", fn ->
      Geofence.start_link({1, "bounding_box", 1, ""})
    end
  end

  test "start_link when webhook url is not valid" do
    assert_raise ArgumentError, "Invalid webhook url", fn ->
      Geofence.start_link({1, "bounding_box", [%Point{x: 1, y: 1}], "invalid-url"})
    end
  end

  test "handle_cast {:handle_point, point} call raycasting_impl.is_inside" do
    point = %Point{x: 1, y: 2}
    geofence = %Geofence{id: 1, type: "bounding_box", value: []}

    expect(HttpClientServiceBehaviorMock, :send, fn _method, _url, _body ->
      true
    end)

    expect(RaycastingBehaviorMock, :is_inside, fn point, polygon ->
      assert point == point
      assert polygon == geofence.value
    end)

    assert Geofence.handle_cast({:handle_point, point}, geofence) == {:noreply, geofence}
  end

  test "handle_cast {:handle_point, point} when point is inside send event with detect inside" do
    point = %Point{x: 1, y: 2}

    polygon = [
      %Point{x: 1, y: 2},
      %Point{x: 3, y: -2},
      %Point{x: 7, y: -3},
      %Point{x: 10, y: 1},
      %Point{x: 7, y: 5},
      %Point{x: 3, y: 5}
    ]

    webhook_url = "https://some-webhook-url"

    geofence = %Geofence{id: 1, type: "bounding_box", value: polygon, webhook: webhook_url}

    expected_event = %GeofenceEvent{
      point_identifier: nil,
      identifier_type: "point.id",
      detect: "inside"
    }

    expect(RaycastingBehaviorMock, :is_inside, fn _point, _polygon ->
      assert true
    end)

    expect(HttpClientServiceBehaviorMock, :send, fn method, url, body ->
      assert method == :post
      assert url == webhook_url
      assert body == expected_event
    end)

    assert Geofence.handle_cast({:handle_point, point}, geofence) == {:noreply, geofence}
  end
end

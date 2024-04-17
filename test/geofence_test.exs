defmodule GeofenceTest do
  use ExUnit.Case

  import Mox

  test "start_link when type is invalid raise ArgumentError" do
    assert_raise ArgumentError, "Invalid geofence type", fn ->
      Geofence.start_link({1, "invalid type", 1})
    end
  end

  test "start_link when value is not a list of Point raise ArgumentError" do
    assert_raise ArgumentError, "Invalid geofence value", fn ->
      Geofence.start_link({1, "bounding_box", 1})
    end
  end

  test "handle_cast {:handle_point, point} call raycasting_impl.is_inside" do
    point = %Point{x: 1, y: 2}
    geofence = %Geofence{id: 1, type: "bounding_box", value: []}

    expect(RaycastingBehaviorMock, :is_inside, fn point, polygon ->
      assert point == point
      assert polygon == geofence.value
    end)

    assert Geofence.handle_cast({:handle_point, point}, geofence) == {:noreply, geofence}
  end
end

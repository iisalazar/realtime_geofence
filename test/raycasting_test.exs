defmodule RaycastingTest do
  use ExUnit.Case

  test "is_inside when point is inside polygon return true" do
    polygon = [
      %Point{x: 1, y: 2},
      %Point{x: 3, y: -2},
      %Point{x: 7, y: -3},
      %Point{x: 10, y: 1},
      %Point{x: 7, y: 5},
      %Point{x: 3, y: 5}
    ]

    point = %Point{x: 4, y: 1}
    assert Raycasting.is_inside(point, polygon) == true
  end

  test "is_inside when point is outside polygon return false" do
    polygon = [
      %Point{x: 1, y: 2},
      %Point{x: 3, y: -2},
      %Point{x: 7, y: -3},
      %Point{x: 10, y: 1},
      %Point{x: 7, y: 5},
      %Point{x: 3, y: 5}
    ]

    point = %Point{x: 1, y: 4}

    assert Raycasting.is_inside(point, polygon) == false
  end
end

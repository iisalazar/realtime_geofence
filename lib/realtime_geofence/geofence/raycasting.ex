defmodule Raycasting do
  @behaviour RaycastingBehavior

  @impl RaycastingBehavior
  def is_inside(point, polygon) do
    is_inside_flag = false
    is_inside_recur_helper(point, polygon, 0, 1, is_inside_flag)
  end

  def compute_x_intersection(point, p1, p2) do
    (point.y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + p1.x
  end

  def is_inside_recur_helper(point, polygon, p1idx, p2idx, is_inside_flag) do
    cond do
      p2idx > length(polygon) ->
        is_inside_flag

      true ->
        p1 = Enum.at(polygon, p1idx)
        p2 = Enum.at(polygon, rem(p2idx, length(polygon)))

        # NOTE you must call the compute_x_intersection after all of the conditions to prevent DivisionByZero error
        cond do
          point.y > min(p1.y, p2.y) && point.y <= max(p1.y, p2.y) && point.x <= max(p1.x, p2.x) &&
              (p1.x == p2.x || point.x <= compute_x_intersection(point, p1, p2)) ->
            is_inside_recur_helper(
              point,
              polygon,
              p1idx + 1,
              p2idx + 1,
              !is_inside_flag
            )

          true ->
            is_inside_recur_helper(
              point,
              polygon,
              p1idx + 1,
              p2idx + 1,
              is_inside_flag
            )
        end
    end
  end
end

defmodule Geofences.Types do
  def bounding_box() do
    :bounding_box
  end

  def polygon() do
    :polygon
  end

  def get_type(type) do
    cond do
      is_valid_type(type) -> {:ok, String.to_atom(type)}
      true -> {:error, "Invalid geofence type"}
    end
  end

  def is_valid_type(type) do
    String.to_atom(type) in [:bounding_box, :polygon]
  end

  def is_valid_value(:bounding_box, value) do
    is_list_of_points(value)
  end

  def is_valid_value(:polygon, value) do
    is_list_of_points(value)
  end

  defp is_list_of_points(value) do
    is_list(value) &&
      Enum.all?(value, fn point -> is_struct(point, Point) end)
  end
end

defmodule RaycastingBehavior do
  @callback is_inside(%Point{}, [%Point{}]) :: boolean
end

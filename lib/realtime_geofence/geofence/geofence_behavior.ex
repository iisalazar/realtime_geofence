defmodule GeofenceBehavior do
  @callback handle_point(any(), Point.t()) :: any()
end

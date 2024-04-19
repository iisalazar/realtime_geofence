defmodule GeofenceEvent do
  defstruct [:point_identifier, :identifier_type, :detect]

  defimpl Jason.Encoder do
    def encode(
          %GeofenceEvent{
            point_identifier: point_identifier,
            identifier_type: identifier_type,
            detect: detect
          },
          opts
        ) do
      Jason.Encode.map(
        %{
          "point_identifier" => point_identifier,
          "identifier_type" => identifier_type,
          "detect" => detect
        },
        opts
      )
    end
  end
end

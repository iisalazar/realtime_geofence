defmodule HttpClientServiceBehavior do
  @callback send(:get, String.t()) :: any()
  @callback send(:post, String.t(), struct()) :: any()
end

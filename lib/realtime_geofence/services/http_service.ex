defmodule HttpClientService do
  @behaviour HttpClientServiceBehavior

  @impl true
  def send(:get, url) do
    Req.get!(url)
  end

  @impl true
  def send(:post, url, body) do
    Req.post!(url, json: body)
  end
end

defmodule DistilTube.StreamFormats.Hls do
  @moduledoc """
  HLS stand for HTTP Live Streaming, a streaming protocol based on HTTP.
  Not supported yet.
  """

  def is_hls?(video_info), do: Map.has_key?(video_info, "hlsvp")

  def parsing(_data) do
    {:err, :hls_not_supported_yet}
  end

end

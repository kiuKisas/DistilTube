defmodule DistilTube.StreamFormats.Rtmp do
  @moduledoc """
  RTMP stand for Real Time Messaging Protocol, network protocol develop by Adobe.
  Is not supported yet.
  """
  def is_rtmp?(video_info) do
    conn = video_info['conn']
    (conn && String.starts_with?(conn, "rtmp"))
  end

  def parsing(_video_info, _player_response) do
    {:err, :rtmp_not_supported_yet}
  end
end

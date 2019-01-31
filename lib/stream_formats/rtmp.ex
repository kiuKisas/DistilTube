defmodule DistilTube.StreamFormats.Rtmp do
  @moduledoc """
    Documentation
  """
  def is_rtmp?(video_info) do
    conn = video_info['conn']
    (conn && String.starts_with?(conn, "rtmp"))
  end

  def parsing(video_info, player_response) do
    { video_info, player_response }
  end
end

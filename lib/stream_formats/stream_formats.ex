defmodule DistilTube.StreamFormats do
  @moduledoc """
  This is where we will guess the type of video based on video_info.
  Fmt is the default format, hls and rtmp are protocols for lives (not supported for now).
  See the respective format folders/files for more informations.
  """

  alias DistilTube.StreamFormats.Fmt
  alias DistilTube.StreamFormats.Rtmp
  alias DistilTube.StreamFormats.Hls

  def formats_list(%{video_info: video_info, js_player_url: js_player_url, player_response: player_response}, _video_id) do
    cond do
      Map.has_key?(video_info, "ypc_video_rental_bar_text") ->
        {:err, :rental_video}
      Rtmp.is_rtmp?(video_info) ->
        Rtmp.parsing(video_info, player_response)
      Fmt.is_fmt?(video_info) ->
        Fmt.parsing(video_info, js_player_url)
      Hls.is_hls?(video_info) ->
        Hls.parsing(video_info)
      true -> {:err, :no_matched_found}
    end
  end

end

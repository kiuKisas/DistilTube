defmodule DistilTube.StreamFormats.Fmt do
  @moduledoc """
  Documentation
  """

  alias DistilTube.StreamFormats.Fmt.EncodedUrlMap
  alias DistilTube.StreamFormats.Fmt.Signature

  # def is_fmt?(encoded_url_map) do
  #   encoded_url_map
  #   |> Enum.each(fn _k, v -> length(Map.keys(v)) >= 1 end)
  #   |> Enum.reduce(&(&1 && &2))
  # end

  def is_fmt?(video_info), do: video_info["url_encoded_fmt_stream_map"] || video_info["adaptive_fmts"]

  def parsing(_, %{'rtmpe' => "yes"}, _), do: {:err, :rtmpe_not_supported}

  def parsing(video_info, js_player_url) do
    %{
      type: :fmt,
      fmt_list: fmt_list(video_info),
      stream_list: stream_list(video_info, js_player_url)
    }
  end

  defp stream_list(video_info, js_player_url) do
    encoded_url_map = EncodedUrlMap.get(video_info) 
    signature_list = encoded_url_map
     |> Enum.map(fn {_name, data} -> Signature.get(data, js_player_url) end)
    %{
      encoded_url_map: encoded_url_map,
      signature_list: signature_list
    }
  end

   defp fmt_list(%{"fmt_list" => fmt_list}) do
    fmt_list
    |> String.split(",")
    |> Enum.map(&(fmt_to_map(&1)))
    |> Enum.into(%{})
  end

  defp fmt_list(_), do: %{}

  defp fmt_to_map(fmt) do
    [itag, resolution] = fmt
                         |> String.split("/")
    [width, height] = resolution
                      |> String.split("x")
    { 
      itag,
      %{
        resolution: resolution,
        width: width,
        height: height
      }
    }
  end

end

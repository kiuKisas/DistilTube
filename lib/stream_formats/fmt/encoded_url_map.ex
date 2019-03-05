defmodule DistilTube.StreamFormats.Fmt.EncodedUrlMap do
  @moduledoc """
  Documentation
  """

  def get(video_info) do
    fmt_stream = (video_info["url_encoded_fmt_stream_map"] || "")
                 |> URI.decode_query
    adaptive_fmts = (video_info["adaptive_fmts"] || "")
                    |> URI.decode_query
    [
      fmt_stream: fmt_stream,
      adaptive_fmts: adaptive_fmts
    ]
  end

  def parse(data) do
    data
    #|> itag_and_url
    #|> Map.merge(player_url(data))
    # |> Map.merge(signature(data))
  end

  # defp player_url(%{"s" => s}) do
  #   # need webpage and be able to rich embed_webpage
  #   %{s: s}
  # end

  # defp player_url(_) do %{} end
  # defp itag_and_url(%{"itag" => itag, "id" => id}) do
  #   %{
  #     itag: itag,
  #     id: id
  #   }
  # end

  # defp itag_and_url(_), do: %{}

end


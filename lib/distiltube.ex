defmodule DistilTube do
  @moduledoc """
  Documentation for DistilTube.
  """
  alias DistilTube.Youtube
  
  def body(id) do
    case Youtube.watch(id) do
      {:ok, response} -> response.body
      {:error, response} -> response
    end
  end

  def ee_info(id) do
    id
    |> body
    |> DistilTube.Info.info(id)
    |> DistilTube.Info.extend_info
  end

  def test(id) do
    id
    |> body
    |> DistilTube.Info.info(id)
    |> DistilTube.Info.extend_info
    |> DistilTube.StreamFormats.formats_list(id)
  end
  #def swf_player_url(body) do
  #   case Regex.run(~r/swfConfig.*?"(https?:\/\/.*?watch.*?-.*?\.swf)"/, body) do
  #    # re.sub(r'\\(.)', r'\1', mobj.group(1))
  #     [_ ,[ url ,_ ]] ->
  #         url
  #        |> String.replace(~r/(.)/, '')
  #        |> String.replace(~r/1/, '')
  #     nil -> nil
  #  end
  #end

  #def player_url(body) do
  #  cond do
  #    data = swf_player_url(body) ->
  #      {:ok, data}
  #    true -> {:error, :media_not_extracted}
  #  end
  #end
  

  # def get_info(data) do
  #   title = cond do
  #     data[:info]["title"] ->
  #       List.first data[:info]["title"]
  #     data[:details] -> data[:details]
  #     true -> 'unknown'
  #   %{
  #     title: title,
  #     description: 'todo with body',
  #     view_count: 'todo'

  #   }
  #   end
  # end

  # refacto 
  def no_token_reason(video_info) do
    video_info
  end
  def extractor(data, body) do
    unless Map.has_key?(data.video_info, :token) do
      no_token_reason(data.video_info)
    else
      %{
        title: List.first(data.video_info.title),
        description: extract_description(body)
      }
    end
  end

  def extract_description(body) do
    cond do
      desc = List.first(Floki.find(body, "eow-description")) -> desc 
      true -> ""
    end
  end

end

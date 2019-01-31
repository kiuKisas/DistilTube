defmodule DistilTube.StreamFormats.Fmt.Signature do
  @moduledoc """
  Documentation
  """

  alias DistilTube.Youtube
  alias DistilTube.StreamFormats.Fmt.JsPlayer

  def get(%{"sig" => sig}, _), do: sig
  def get(%{"s" => s}, js_player_url),
    do: decrypt(s, js_player_url)
  def get(_, _), do: nil

  defp decrypt(_s, js_player_url) do
    case Youtube.get(js_player_url) do
      {:err, err} -> {:err, err}
      {:ok, %{body: player_body}} ->
        player_body
        |> JsPlayer.to_cypher_data
        |> to_actions
    end
  end

  defp to_actions(cypher_data) do
    cypher_data
  end
  
  # if we use a cach
  # defp signature_patch_id(id) do
  #  id
  #  |> String.split(".")
  #  |> Enum.map(&( &1 |> length |> Integer.to_string))
  #  |> Enum.join(".")
  #end
end

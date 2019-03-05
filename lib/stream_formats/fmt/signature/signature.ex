defmodule DistilTube.StreamFormats.Fmt.Signature do
  @moduledoc """
  Get youtube video signature and decipher it if needed
  """

  alias DistilTube.Youtube
  alias DistilTube.StreamFormats.Fmt.Signature.Cipher

  def get(%{"sig" => sig}, _), do: sig
  def get(%{"s" => s}, js_player_url),
    do: decipher(s, js_player_url)
  def get(_, _), do: nil

  defp decipher(s, js_player_url) do
    # TODO: add cache for js_player to save some network call
    case Youtube.get(js_player_url) do
      {:err, err} -> {:err, err}
      {:ok, %{body: player_body}} ->
        player_body
        |> Cipher.data
        |> Cipher.decipher(s)
    end
  end

end

defmodule DistilTube.StreamFormats.Fmt.JsPlayer do
  @moduledoc """
  Dovumetrklng
  """

  defp functname_regex(js_player_body) do
    Regex.run(~r/(["\'])signature\1\s*,\s*(?P<>[a-zA-Z0-9$]+)\(/, js_player_body)
    || Regex.run(~r/\.sig\|\|(?P<>[a-zA-Z0-9$]+)\(/, js_player_body)
    || Regex.run(~r/yt\.akamaized\.net\/\)\s*\|\|\s*.*?\s*c\s*&&\s*d\.set\([^,]+\s*,\s*(?:encodeURIComponent\s*\()?(?P<>[a-zA-Z0-9$]+)\(/, js_player_body)
    || Regex.run(~r/\bc\s*&&\s*d\.set\([^,]+\s*,\s*(?:encodeURIComponent\s*\()?\s*(?P<>[a-zA-Z0-9$]+)\(/, js_player_body)
    || Regex.run(~r/\bc\s*&&\s*d\.set\([^,]+\s*,\s*\([^)]*\)\s*\(\s*(?P<>[a-zA-Z0-9$]+)\(/, js_player_body)
  end

  defp function_regex(js_player_body, funcname) do
      funcname_regex = Regex.escape(funcname)
      pattern = "(?x)(?:function\\s+"
                <> funcname_regex
                <> "|[{;,]\\s*"
                <> funcname_regex
                <> "\\s*=\\s*function|var\\s+" 
                <> funcname_regex
                <> "\\s*=\0\\s*function)\\s*"
                <> "\((?P<args>[^)]*)\)\\s*"
                <> "\{(?P<code>[^}]+)\}"
      {:ok, regex} = Regex.compile(pattern)
			IO.inspect regex
      Regex.run(regex, js_player_body)
  end

  defp extract_function(funcname, js_player_body) do
    function_regex(js_player_body, funcname)
  end

  defp cypher_functs(js_player_body) do
    ## NB: group ? always ?
    case functname_regex(js_player_body) do
      nil -> 
        {:err, :cant_extract_functname}
      res -> 
        { res,
        res
        |> List.last
        |> extract_function(js_player_body) }
      end
  end

  defp cypher_order(js_player_body) do
    js_player_body
  end 

  def to_cypher_data(js_player_body) do
    %{
      order: cypher_order(js_player_body),
      functs: cypher_functs(js_player_body)
    }
  end

  ## Signature/cypher
end

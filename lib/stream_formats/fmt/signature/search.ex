defmodule DistilTube.StreamFormats.Fmt.Signature.Search do
  @moduledoc """
  Regex matching signature cipher informations from js_player body.
  """

  def object(js_player_body, objname) do
    pattern = "(?x)(?<!this\.)"
    <> Regex.escape(objname)
    <> "\\s*=\\s*{\\s*(?P<fields>("
    <> "(?:[a-zA-Z$0-9]+|\"[a-zA-Z$0-9]+\"|'[a-zA-Z$0-9]+')"
    <> "\\s*:\\s*function\\s*\\(.*?\\)\\s*{.*?}(?:,\\s*)?)*)}\\s*"
    {:ok, regex} = Regex.compile(pattern)
    ret = Regex.named_captures(regex, js_player_body)
		ret
  end

  def notice(js_player_body, funcname) do
    funcname_regex = Regex.escape(funcname)
    pattern = "(?x)(?:function\\s+"
              <> funcname_regex
              <> "|[{;,]\\s*"
              <> funcname_regex
              <> "\\s*=\\s*function|var\\s+"
              <> funcname_regex
              <> "\\s*=\\s*function)\\s*"
              <> "\\((?P<argname>[^)]*)\\)\\s*"
              <> "\\{(?P<actions>[^}]+)\\}"
    {:ok, regex} = Regex.compile(pattern)
    Regex.named_captures(regex, js_player_body)
  end

  def init_function(js_player_body) do
    Regex.named_captures(~r/(["\'])signature\1\s*,\s*(?P<name>[a-zA-Z0-9$]+)\(/, js_player_body)
    || Regex.named_captures(~r/\.sig\|\|(?P<name>[a-zA-Z0-9$]+)\(/, js_player_body)
    || Regex.named_captures(~r/yt\.akamaized\.net\/\)\s*\|\|\s*.*?\s*c\s*&&\s*d\.set\([^,]+\s*,\s*(?:encodeURIComponent\s*\()?(?P<name>[a-zA-Z0-9$]+)\(/, js_player_body)
    || Regex.named_captures(~r/\bc\s*&&\s*d\.set\([^,]+\s*,\s*(?:encodeURIComponent\s*\()?\s*(?P<name>[a-zA-Z0-9$]+)\(/, js_player_body)
    || Regex.named_captures(~r/\bc\s*&&\s*d\.set\([^,]+\s*,\s*\([^)]*\)\s*\(\s*(?P<name>[a-zA-Z0-9$]+)\(/, js_player_body)
  end

end

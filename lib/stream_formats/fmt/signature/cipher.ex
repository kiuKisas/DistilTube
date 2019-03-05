defmodule DistilTube.StreamFormats.Fmt.Signature.Cipher do
  @moduledoc """
  Extract a functions dictionary and a notice to decipher
  a youtube video signature from js_player body; Then decipher
  a given signature with these data
  """

  alias DistilTube.StreamFormats.Fmt.Signature.Search

  # Return formatted actions from actions_raw
  #
  ## Exemple:
  # iex> actions_format("lv.Ym(a,25);...")
  # [["lv", "Ym", "a,25"]]

  defp actions_format(actions_raw) do
    actions_raw
    |> String.split(";")
    |> Enum.map(&(
      ~r/(?P<obj>.*)\.(?P<func>.*)\((?P<args>.*)\)/
        |> Regex.named_captures(&1)
        |> function_args_format
    ))
  end

  defp objname_from_action(%{"obj" => objname}) do
    objname
    |> String.contains?(["=", "return"])
    |> (fn unvalid -> if unvalid, do: nil, else: objname end).()
  end

  defp objnames_from_actions(actions) do
    actions
    |> Enum.map(&objname_from_action/1)
    |> Enum.uniq
    |> Enum.reject(&is_nil/1)
  end

  defp notice_update(notice) do
    actions_formated = notice
                       |> Map.fetch!("actions")
                       |> actions_format
    Map.merge(
      Map.replace!(notice, "actions", actions_formated),
      %{"objnames" => objnames_from_actions(actions_formated) }
    )
  end

  defp notice(js_player_body, funcname) do
    case Search.notice(js_player_body, funcname) do
      nil -> {:err, :cant_extract_notice}
      data -> {:ok, notice_update(data)}
    end
  end

  defp gen_dictionary(object_raw) do
    object_raw
    |> Map.fetch!("fields")
    |> String.split(",\n")
    |> Enum.map(fn function_raw ->
      function_raw
      |> function_separator
      |> function_args_format
      |> function_format
    end)
    |> Enum.into(%{})
  end

  defp function_args_format(nil) do
    nil
  end

  defp function_args_format(function) do
    Map.update!(function, "args", &(String.split(&1, ",")))
  end

  defp function_format(function) do
    {%{"key" => key}, content } = Map.split(function, ["key"])
    {key, content}
  end

  defp function_separator(function_raw) do
    ~r/(?x)(?P<key>(?:[a-zA-Z$0-9]+|\"[a-zA-Z$0-9]+\"|'[a-zA-Z$0-9]+'))\s*:\s*function\s*\((?P<args>[a-z,]+)\){(?P<code>[^}]+)}/
      |> Regex.named_captures(function_raw)
  end

  # see how to make a global ok/err, maybe stop the loop if one err ?
  # see reduce maybe ?
  defp dictionary(js_player_body, %{"objnames" => objnames}) do
    objnames
    |> Enum.map(fn objname ->
      { objname,
        case Search.object(js_player_body, objname) do
          nil -> {:err, :cant_extract_object}
          object -> {:ok, gen_dictionary(object)}
        end
      }
    end)
    |> Enum.into(%{})
  end

  def data(js_player_body) do
    with %{"name" => funcname} <- Search.init_function(js_player_body),
         {:ok, notice} <- notice(js_player_body, funcname),
         dictionary <- dictionary(js_player_body, notice) do
      {:ok, %{
        notice: notice,
        dictionary: dictionary
      }}
    else
      {:err, err} -> {:err, err}
      nil -> {:err, :cant_find_init_function_name}
    end
  end

  def decipher(data, _s) do
    data
    # PRE
    #  decode dictionary code
    #
    #  * checker si c'est une fonctionne systeme split, join
    #    -> effectuer ou je ne sais pas quoi
    #  * Sinon prendre l'objet dans le dico, regarder fonction
    #    ->  executer la fonction
  end

end

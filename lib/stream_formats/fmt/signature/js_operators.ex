defmodule DistilTube.StreamFormats.Fmt.Signature.Functions do

  def functions, do: %{
    "split" => &split/1,
    "join" => &join/1,
    "reverse" => &Enum.reverse/1,
    "splice" => &splice/1,
    "swap" => &swap/1
  }

  defp split(s), do: s |> String.codepoints
  defp join(cl), do: cl |> List.to_string
  defp splice([cl, amount]), do: cl |> Enum.slice(0, amount)
  defp swap([cl, b]) do
    pos = rem(b, length(cl))
    cl
    |> List.replace(pos, Enum.at(cl, 0))
    |> List.replace(0, Enum.at(cl, pos))
  end
end

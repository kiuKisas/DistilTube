defmodule DistilTube.Info do
  @moduledoc """
  Documentation for DistilTube.Data
  """
  alias DistilTube.Youtube

  defp embed_sts({:ok, %Tesla.Env{body: embed_body}}),
    do: Regex.run(~r/"sts"\s*:\s*(\d+)/, embed_body)

  defp player_url_assets_regex({:ok, %Tesla.Env{body: body}}),
    do: Regex.run(~r/"assets":.+?"js":\s*("[^"]+")/, body)

  defp player_url_assets_regex(body),
    do: Regex.run(~r/"assets":.+?"js":\s*("[^"]+")/, body)

  defp player_url_ytplayer_regex(body),
    do: Regex.run(~r/ytplayer\.config.*?"url"\s*:\s*("[^"]+")/, body)

  def info(body, video_id) do
    # to refacto
    cond do
      Regex.run(~r/player-age-gate-content">/, body) -> {
          :ok,
          age_gate_info(video_id)
      }
      config = ytplayer_config(body) ->
        base_info = config_info(config)
        if {:ok, info} = base_info do
         js_player_url = config_player_url(body, video_id)
                       |> List.last
                       |> Jason.decode!
          # need more inspection when to use it, token ?
          # video_id
          #|> rec_get_video_info(info[:sts], ["info", "embedded", "detailpage", "vevo", ""])
          #|> compact_info(info)
          {
            :ok,
             Map.merge(info, %{
              js_player_url: js_player_url
            })
          }
        else
          base_info
        end
      true -> {:err, :no_info_extracted}
    end
  end

  defp config_player_url(body, video_id) do
    player_url_assets_regex(body)
    || get_embed_player_url(video_id)
    || player_url_ytplayer_regex(body)
  end

  defp get_embed_player_url(video_id) do
    video_id
    |> Youtube.embed
    |> player_url_assets_regex
  end

  defp age_gate_info(video_id) do
    # TO REFACTO ++ MORE SECURE AROUND CONNEXION
    embed = Youtube.embed(video_id)
    {:ok, %Tesla.Env{body: embed_body}} = embed
    sts = embed
          |> embed_sts
          |> List.last
    {:ok, %Tesla.Env{body: video_info_body}} = Youtube.video_info(video_id, sts)
    video_info = URI.decode_query(video_info_body)
    player_url = player_url_assets_regex(embed_body) ||
      player_url_ytplayer_regex(embed_body)
    %{
      sts: sts,
      video_info: video_info,
      player_url: player_url,
      dashmpds: video_info["dashmpd"] || [],
      age_gate: true,
      live: false
    }
  end

  defp config_info(%{"args" => args, "sts" => sts}) do
    live = if args["livestream"] || args["live_playback"], do: true, else: false
    {
      :ok,
      %{
        sts: sts,
        video_info: args,
        dashmpds: args["dashmpd"] || [],
        age_gate: false,
        live: live
      }
    }
  end

  defp config_info(%{"args" => %{"ypc_id" => _}}), do: {:error, :rental_video}

  def compact_info(extra, info) do
    info
    |> Map.update(:dashmpds,
      extra[:dashmpds],
      &(Enum.concat(extra[:dashmpds], &1))
    )
    |> Map.update(:video_info,
      extra[:video_info],
      &(&1 || extra[:video_info])
    )
    |> Map.update(:token,
      extra[:token],
      &(&1 || extra[:token])
    )
  end

  def ytplayer_config(body) do
    if data = Regex.run(~r/;ytplayer\.config\s*=\s*({.+?});/, body) do
      data
      |> List.last
      |> Jason.decode!
    else
      nil
    end
  end

  defp rec_get_video_info(video_id, sts, [el | acc]) do
    {:ok, %Tesla.Env{body: el_body}} = Youtube.video_info(video_id, sts, el)
    el_info = el_body
              |> URI.decode_query
    dashmpds = el_info["dashmpd"] || []
    if Map.has_key?(el_info, "token") do
      %{
        video_info: el_info,
        token: el_info["token"],
        dashmpds: dashmpds
       }
    else
      rec_get_video_info(video_id, sts, acc)
      |> Map.update(:dashmpds, dashmpds, &(Enum.concat(dashmpds, &1)))
    end
  end

  defp rec_get_video_info(_, _, []), do: %{video_info: '', dashmpds: [], token: false}


  def extend_info({:ok, info}) do
    # nested update mf
    {video_details, player_response} = info[:video_info]["player_response"]
                      |> Jason.decode!
                      |> Map.pop("videoDetails")
    info
    |> Map.update!(:video_info, &(Map.delete(&1, "player_response")))
    |> Map.merge(%{
      player_response: player_response,
      video_details: video_details
    })
      #%{
      #%{info: info,
      #%{player_response: player_response_clean,
      #%{details: Jason.decode!(video_details)
      #}
  end

  def extend_info(err), do: err

end

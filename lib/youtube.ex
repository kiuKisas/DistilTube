defmodule DistilTube.Youtube do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://www.youtube.com"

  def watch(id) do
    get("/watch?v=" <> id <> "&gl=US&hl=en&has_verified=1&bpctr=9999999999")
  end

  def embed(id) do
    get("/embed/" <> id)
  end

  def video_info(id, sts) do
    query = [
      video_id: id,
      eurl: "https://youtube.googleapis.com/v/" <> id,
      sts: sts
    ]

    get("/get_video_info", query: query)
  end

  def video_info(id, sts, el) do
    query = [
      video_id: id,
      eurl: '',
      gl: 'US',
      hl: 'en',
      sts:  sts,
      el: el
    ]
    get("/get_video_info", query: query)
  end

  def get_url(url), do: get(url)
end

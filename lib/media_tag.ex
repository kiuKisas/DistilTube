defmodule MediaTag do
  alias __MODULE__
  @enforce_keys [:id, :type, :format, :bitrate]

  defstruct(
    id: 0,
    type: "",
    format: "",
		bitrate: 0
  )
end

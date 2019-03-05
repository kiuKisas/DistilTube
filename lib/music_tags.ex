defmodule DictTags do
  def musics, do: [
    %MediaTag{id: 171, type: :audio, format: "webma", bitrate: 128},
    %MediaTag{id: 172, type: :audio, format: "webma", bitrate: 256},
    %MediaTag{id: 139, type: :audio, format: "m4a", bitrate: 48},
    %MediaTag{id: 140, type: :audio, format: "m4a", bitrate: 128},
    %MediaTag{id: 141, type: :audio, format: "m4a", bitrate: 256},
    %MediaTag{id: 249, type: :audio, format: "opus", bitrate: 50},
    %MediaTag{id: 250, type: :audio, format: "opus", bitrate: 70},
    %MediaTag{id: 251, type: :audio, format: "opus", bitrate: 160}
  ]
end

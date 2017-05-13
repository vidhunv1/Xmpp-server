defmodule Spotlight.MessageDataView do
  use Spotlight.Web, :view

  def render("message_image.json", %{user: user, image: image}) do
    %{
      data_url: SpotlightApi.ImageUploader.url({image, user})
    }
  end

  def render("message_audio.json", %{user: user, audio: data_url}) do
    %{
      data_url: data_url
    }
  end
end

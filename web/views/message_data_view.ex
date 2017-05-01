defmodule Spotlight.MessageDataView do
  use Spotlight.Web, :view
  def render("message_image.json", %{user: user, image: image}) do
    %{
      data_url: SpotlightApi.ImageUploader.url({image, user})
    }
  end
end

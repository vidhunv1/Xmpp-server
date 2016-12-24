defmodule Spotlight.Contact do  
  use Spotlight.Web, :model

  alias Spotlight.User

  schema "contacts" do
  	field :has_added_back	, :boolean, default: false
    belongs_to :user, User
    belongs_to :contact, User
  end
end  
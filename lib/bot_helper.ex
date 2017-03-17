defmodule BotHelper do
  require Logger  

  def forward_message(from_user_id, message, url) do
    headers = [{"Content-type", "application/json"}]
    body = "{\"from_id\": \"#{from_user_id}\", \"message\": #{message}}"
    
    case HTTPoison.post(url<>"/message", body, headers) do
    	{:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
          {:error, "Invalid status code returned"}
      {:error, %HTTPoison.Error{reason: reason}} ->      
        {:error, reason}
    end
  end
end
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

  def send_app_init(from_user_id, name, mobile_number, url) do
    headers = [{"Content-type", "application/json"}]
    body = "{\"from_id\": \"#{from_user_id}\", \"name\": \"#{name}\", \"phone\": \"#{mobile_number}\"}"

    Logger.info(body)

    case HTTPoison.post(url<>"/init", body, headers) do
    	{:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
          {:error, "Invalid status code returned"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def send_add_hook(from_user_id, name, mobile_number, url) do
    headers = [{"Content-type", "application/json"}]
    body = "{\"from_id\": \"#{from_user_id}\", \"name\": \"#{name}\", \"phone\": \"#{mobile_number}\"}"

    Logger.info(body)

    case HTTPoison.post(url<>"/add", body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
          {:error, "Invalid status code returned"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def send_on_transaction(from_user_id, transaction_id, transaction_secret, amount, status, productinfo, url) do
    headers = [{"Content-type", "application/json"}]
    body = "{\"from_id\": \"#{from_user_id}\", \"transaction_id\": \"#{transaction_id}\", \"transaction_secret\": \"#{transaction_secret}\", \"amount\": \"#{amount}\", \"status\": \"#{status}\", \"product_info\": \"#{productinfo}\"}"
    Logger.info(body)

    case HTTPoison.post(url<>"/transaction", body, headers, [recv_timeout: 100000, timeout: 100000]) do
    	{:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
          {:error, "Invalid status code returned"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end

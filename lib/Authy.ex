defmodule Authy do
  require Logger	
  use HTTPoison.Base

  @expected_fields ~w(
    carrier is_cellphone message seconds_to_expire uuid success
  )

  def process_url(url) do
    "https://api.authy.com/protected/json/phones/verification" <> url
  end

  def api_key do
  	Application.get_env(:spotlight_api, :authy_api_token)
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Map.take(@expected_fields)
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end

  def start_verification(country_code, phone) do
  	Authy.start

  	if is_binary(api_key) do
  		headers = %{"Content-Type" => "application/x-www-form-urlencoded", "X-Authy-API-Key" => api_key}
  		body = {:form, [via: "sms", phone_number: phone, country_code: country_code]}

  		case Authy.post("/start", body, headers) do
  			{:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
  				{:ok, body}
  			{:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
  				{:error, body[:message]}
  			{:error, %HTTPoison.Error{reason: reason}} ->
  				# Logger.warn("Authy: error making verification request." <> reason)
  				{:error, reason}
  		end

  	end
  end
end
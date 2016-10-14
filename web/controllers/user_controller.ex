defmodule Spotlight.UserController do
  require Logger
  use Spotlight.Web, :controller

  alias Spotlight.User

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:update]

  def create(conn, %{"user" => %{"phone" => phone, "country_code" => country_code}}) do
    case Authy.send_otp(country_code, phone) do
      {:ok, message} ->
        user_params = %{"phone" => phone, 
                        "country_code" => country_code, 
                        "phone_formatted" => country_code<>phone, 
                        "mobile_carrier" => message[:carrier], 
                        "is_cellphone" => message[:is_cellphone], 
                        "verification_uuid" => message[:uuid]}
        changeset = User.create_changeset(%User{}, user_params)

        case Repo.insert(changeset) do
          {:ok, _user} ->
            conn
            |> put_status(:created)
            |> render("status.json", %{status: "success", message: "OTP sent to number +"<>country_code<>" "<>phone})  
          {:error, _changeset} ->
            # phone: {"has already been taken"}
            conn
            |> put_status(200)
            |> render("status.json", %{status: "success", message: "OTP sent to number +"<>country_code<>" "<>phone})  
        end

      {:error, message} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", %{message: message, code: 422})  
    end
  end

  def verify(conn, %{"user" => %{"phone" => phone, "country_code" => country_code, "verification_code" => verification_code}}) do
    case Authy.verify_otp(country_code, phone, verification_code) do
      {:ok, 200, _body} ->
        user = Repo.get_by(User, phone_formatted: country_code<>phone)
        user_changes  =  %{"is_registered" => true}
        changeset = User.verify_changeset(user, user_changes)
        
        case Repo.update(changeset) do
          {:ok, updated_user} ->
            #Generate user access, refresh tokens
            new_conn = Guardian.Plug.api_sign_in(conn, user)
            jwt = Guardian.Plug.current_token(new_conn)
            {:ok, %{"exp" => exp}} = Guardian.Plug.claims(new_conn)

            new_conn
            |> put_status(201)
            |> put_resp_header("authorization", "Bearer "<>jwt)
            |> put_resp_header("x-expires", to_string(exp))
            |> render("verified_token.json", %{user: updated_user, access_token: "Bearer "<>jwt, exp: to_string(exp)})
          {:error, _reason} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render("error.json", %{message: "No user found", code: 422})
        end

      {:ok, status, _body} ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", %{message: "Incorrect OTP", code: status})

      {:error, _reason} ->
        conn
        |> put_status(:internal_server_error)
        |> render("error.json", %{message: "Error sending SMS", code: 500})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.json", user: user)
  end 

  def update(conn, %{"user" => user_params}) do
     user = Guardian.Plug.current_resource(conn)
     changeset = User.update_changeset(user, user_params)

     case Repo.update(changeset) do
       {:ok, user} ->
         render(conn, "show.json", user: user)
       {:error, changeset} ->
         conn
         |> put_status(:unprocessable_entity)
         |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
     end
   end
end

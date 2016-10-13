defmodule Spotlight.UserController do
  require Logger
  use Spotlight.Web, :controller

  alias Spotlight.User

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
          {:ok, user} ->
            conn
            |> put_status(:created)
            |> render("status.json", %{status: "success", message: "OTP sent to number +"<>country_code<>" "<>phone})  
          {:error, changeset} ->
            # phone: {"has already been taken"}
            conn
            |> put_status(200)
            |> render("status.json", %{status: "success", message: "OTP sent to number +"<>country_code<>" "<>phone})  
        end

      {:error, message} ->
        conn
        |> put_status(200)
        |> render("error.json", %{message: message, code: 400})  
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
            conn
            |> put_status(201)
            |> render("show.json", %{user: updated_user, message: "OTP verify success.", status: "success"})
          {:error, _reason} ->
            conn
            |> render("error.json", %{message: "No user found.", code: ""})
        end

      {:ok, status, _body} ->
        conn
        |> render("error.json", %{message: "Incorrect OTP", code: status})

      {:error, _reason} ->
        conn
        |> render("error.json", %{message: "Error with sms", code: 500})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.json", user: user)
  end 

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
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
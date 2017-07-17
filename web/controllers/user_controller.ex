defmodule Spotlight.UserController do
  require Logger
  use Spotlight.Web, :controller

  alias Spotlight.User

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:update, :logout]

  def create(conn,
    %{"user" =>
      %{"country_code" => country_code,
        "phone" => mobile_number,
        "user_type" => user_type,
        "imei" => imei} }) do

    country_code = country_code |> String.replace("+", "")
    user_id = country_code<>mobile_number
    check_user = Repo.get_by(User, [user_id: user_id])
    is_user_exists = !is_nil(check_user)

    user_params = %{"phone" => mobile_number,
                    "country_code" => country_code,
                    "user_type" => user_type,
                    "imei" => imei,
                    "mobile_carrier" => "",
                    "otp_provider_message" => "",
                    "verification_uuid" => ""}
    if(user_type != "regular") do
      conn
        |> put_status(200)
        |>  render(Spotlight.ErrorView, "error.json", %{title: "", message: "Invalid user type.", code: 401})
    else
      {is_otp_sent, v_carrier, v_message, v_uuid} = case {Authy.send_otp(country_code, mobile_number), user_type} do
        {{:ok, [carrier: c, is_cellphone: true, message: m, seconds_to_expire: _, success: true, uuid: u]}, "regular"} ->
          {true, c, m, u}
            _ ->
              {false, "", "", ""}
      end

      if(is_user_exists) do
        verify_user_changes  =  %{"verification_uuid" => v_uuid}
        verify_changeset = Spotlight.User.verify_changeset(check_user, verify_user_changes)
        case Repo.update(verify_changeset) do
          {:ok, _} ->
            conn
              |> put_status(:ok)
              |> render("create.json", %{user: check_user, is_otp_sent: is_otp_sent, verification_uuid: v_uuid})
          _ ->
            conn
              |> put_status(:ok)
              |> render(Spotlight.ErrorView, "error.json", %{title: "", message: "Could not create user.", code: 500})
        end

      else
        user_params = %{user_params | "mobile_carrier" => v_carrier}
        user_params = %{user_params | "otp_provider_message" => v_message}
        user_params = %{user_params | "verification_uuid" => v_uuid}

        username =
          case user_type do
            "regular" ->
              "u_"<>user_id
              "official" -> "o_"<>user_id
              _ -> ""
          end
          user_params = Map.put(user_params, "is_registered", true)
          user_params = Map.put(user_params, "username", username)
          user_params = Map.put(user_params, "user_type", user_type)
          user_params = Map.put(user_params, "user_id", user_id)

          changeset = User.create_changeset(%User{}, user_params)

          case Repo.insert(changeset) do
            {:ok, _} ->
              usr = Repo.get_by(User, [username: username])
              conn
                |> put_status(:ok)
                |> render("create.json", %{user: usr, is_otp_sent: is_otp_sent, verification_uuid: v_uuid})
            {:error, changeset} ->
              conn
                |> put_status(:ok)
                |> render("create_error.json", changeset: changeset)
            end
          end
    end
  end

  def verify(conn, %{"country_code" => country_code, "phone" => phone, "verification_code" => verification_code, "verification_uuid" => verification_uuid, "password" => password, "notification_token" => notification_token}) do
    case Authy.verify_otp(country_code, phone, verification_code) do
      {:ok, 200, [message: _, success: true]} ->
        user = Repo.get_by(User, [phone: phone, verification_uuid: verification_uuid])
        verify_user_changes  =  %{"is_phone_verified" => true, "notification_token" => notification_token}
        verify_changeset = Spotlight.User.verify_changeset(user, verify_user_changes)
        case Repo.update(verify_changeset) do
          {:ok, _} ->
            new_conn = Guardian.Plug.api_sign_in(conn, user)
            jwt = Guardian.Plug.current_token(new_conn)
            {:ok, %{"exp" => exp}} = Guardian.Plug.claims(new_conn)
            host = Application.get_env(:spotlight_api, Spotlight.Endpoint)[:url][:host]
            case :ejabberd_auth.set_password(user.username, host, password) do
              :ok ->
                new_conn
                  |> put_status(:ok)
                  |> put_resp_header("authorization", "Bearer "<>jwt)
                  |> put_resp_header("x-expires", to_string(exp))
                  |> render("verified_token.json", %{user: user, access_token: "Bearer "<>jwt, exp: to_string(exp), is_verification_success: true})
                _ ->
                  conn
                  |> put_status(:ok)
                  |> render(Spotlight.ErrorView, "error.json", %{title: "", message: "Could not create user.", code: 422})
            end
          _ ->
            conn
              |> put_status(422)
              |> render("status.json", %{message: "An error occured", status: "failure"})
        end
      _ ->
        conn
          |> put_status(:ok)
          |> render(Spotlight.ErrorView, "error.json", %{title: "Wrong OTP", message: "Incorrect OTP", code: 401})
    end
  end

  def create_official(conn, %{"user_id" => user_id, "auth" => auth, "password" => password, "name" => name}) do
    if(auth != "v3v3") do
        conn
          |> put_status(:ok)
          |> render(Spotlight.ErrorView, "error.json", %{title: "", message: "Nut authorized", code: 402})
    end
    username = "o_"<>user_id
    user_params = %{"phone" => "9999999999",
      "country_code" => "91",
      "name" => name,
      "user_type" => "official",
      "imei" => "imei",
      "mobile_carrier" => "",
      "otp_provider_message" => "",
      "user_id" => user_id,
      "username" => username,
      "verification_uuid" => ""}

    check_user = Repo.get_by(User, [user_id: user_id])
    is_user_exists = !is_nil(check_user)

    if(is_user_exists) do
      conn
        |> put_status(:ok)
        |> render(Spotlight.ErrorView, "error.json", %{title: "", message: "Could not create user. User exists.", code: 401})
    else
      
      changeset = User.create_changeset(%User{}, user_params)
      
      case Repo.insert(changeset) do
        {:ok, _} ->
          usr = Repo.get_by(User, [username: username])
          new_conn = Guardian.Plug.api_sign_in(conn, usr)
          jwt = Guardian.Plug.current_token(new_conn)
          {:ok, %{"exp" => exp}} = Guardian.Plug.claims(new_conn)
          host = Application.get_env(:spotlight_api, Spotlight.Endpoint)[:url][:host]
          case :ejabberd_auth.set_password(usr.username, host, password) do
            :ok ->
              new_conn
                |> put_status(:ok)
                |> put_resp_header("authorization", "Bearer "<>jwt)
                |> put_resp_header("x-expires", to_string(exp))
                |> render("verified_token.json", %{user: usr, access_token: "Bearer "<>jwt, exp: to_string(exp), is_verification_success: true})
              _ ->
                conn
                  |> put_status(:ok)
                  |> render(Spotlight.ErrorView, "error.json", %{title: "", message: "Could not create user.", code: 422})
            end
          {:error, changeset} ->
            conn
              |> put_status(:ok)
              |> render("create_error.json", changeset: changeset)
        end
      end
  end

  def login(conn,
    %{"user" =>
      %{"email" => email,
        "password" => password,
        "notification_token" => notification_token
        }}) do

    host = Application.get_env(:spotlight_api, Spotlight.Endpoint)[:url][:host]
    user = Repo.get_by(User, [email: email, is_registered: true])

    if(is_nil(user)) do
      conn
        |> put_status(:ok)
        |> render(Spotlight.ErrorView, "error.json", %{title: "Not found", message: "Could not find user with the email ID.", code: 422})
    else
      if :ejabberd_auth.check_password(user.username, "", host, password) do
        new_conn = Guardian.Plug.api_sign_in(conn, user)
        jwt = Guardian.Plug.current_token(new_conn)
        {:ok, %{"exp" => exp}} = Guardian.Plug.claims(new_conn)
        changeset = User.update_changeset(user, %{"notification_token" => notification_token})
        Repo.update(changeset)
        new_conn
         |> put_status(:ok)
          |> put_resp_header("authorization", "Bearer "<>jwt)
          |> put_resp_header("x-expires", to_string(exp))
          |> render("verified_token.json", %{user: user, access_token: "Bearer "<>jwt, exp: to_string(exp), is_otp_sent: nil, verification_uuid: nil})
      else
        conn
          |> put_status(:ok)
          |> render(Spotlight.ErrorView, "error.json", %{title: "Invalid password", message: "Please enter a valid password.", code: 401})
      end
    end
  end

  def login(conn,
    %{"user" =>
      %{"user_id" => user_id,
        "password" => password,
        "notification_token" => notification_token
        }}) do

    host = Application.get_env(:spotlight_api, Spotlight.Endpoint)[:url][:host]
    user = Repo.get_by(User, [user_id: user_id, is_registered: true])

    if(is_nil(user)) do
      conn
        |> put_status(:ok)
        |> render(Spotlight.ErrorView, "error.json", %{title: "Not found", message: "Could not find user with the ID.", code: 422})
    else
      if :ejabberd_auth.check_password(user.username, "", host, password) do
        new_conn = Guardian.Plug.api_sign_in(conn, user)
        jwt = Guardian.Plug.current_token(new_conn)
        {:ok, %{"exp" => exp}} = Guardian.Plug.claims(new_conn)
        changeset = User.update_changeset(user, %{"notification_token" => notification_token})
        Repo.update(changeset)
        new_conn
          |> put_status(:ok)
          |> put_resp_header("authorization", "Bearer "<>jwt)
          |> put_resp_header("x-expires", to_string(exp))
          |> render("verified_token.json", %{user: user, access_token: "Bearer "<>jwt, exp: to_string(exp), is_otp_sent: nil, verification_uuid: nil})
      else
        conn
          |> put_status(:ok)
          |> render(Spotlight.ErrorView, "error.json", %{title: "Invalid password", message: "Please enter a valid password.", code: 401})
      end
    end
  end

  def update(conn, %{"user" => %{"user_id" => user_id}}) do
    user = Guardian.Plug.current_resource(conn)
    IO.inspect user
    user_id = String.downcase(user_id)

    username = case user.user_type do
      "regular" -> "u_"<>user_id
      "official" -> "o_"<>user_id
      _ -> ""
    end
    changeset = User.update_changeset(user, %{"user_id" => user_id, "username" => username})

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show_update.json", user: user)
      {:error, changeset} ->
        Logger.debug inspect(changeset)
        conn
        |> put_status(:ok)
        |> render("update_error.json", changeset: changeset)
    end
  end

  def update(conn, %{"profile_dp" => image_data}) do
    user = Guardian.Plug.current_resource(conn)
    changeset = Spotlight.User.update_changeset(user, %{"profile_dp" => image_data})

    IO.inspect changeset

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show_update.json", user: user)
      {:error, changeset} ->
        Logger.debug inspect(changeset)
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"user" => user_params}) do
    user = Guardian.Plug.current_resource(conn)
    changeset = User.update_changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show_update.json", user: user)
      {:error, changeset} ->
        Logger.debug inspect(changeset)
        conn
        |> put_status(:ok)
        |> render("update_error.json", changeset: changeset)
    end
  end

  def logout(conn, %{}) do
    user = Guardian.Plug.current_resource(conn)
    changeset = Spotlight.User.update_changeset(user, %{"notification_token" => "", "is_active" => false})

    case Repo.update(changeset) do
      {:ok, _} ->
        conn
          |> put_status(:ok)
          |> render("status.json", %{message: "Logged out successfully.", status: "success"})
      {:error, _} ->
        conn
          |> put_status(:ok)
          |> render(Spotlight.ErrorView, "error.json", %{title: "Error", message: "Error logging out.", code: 400})
    end
  end

  def show(conn, %{"username" => username}) do
    case Repo.get_by(User, [username: username, is_registered: true]) do
      nil -> conn |> put_status(200) |> render(Spotlight.ErrorView, "error.json", %{title: "Not found", message: "Could not find user with the ID.", code: 404})
      user -> render(conn, "show.json", user: user)
    end
  end

  def show(conn, %{"user_id" => user_id}) do
    # IO.inspect conn
    user = Guardian.Plug.current_resource(conn)

    if(!is_nil(user) && user.user_type == "official") do
      case Repo.get_by(User, [user_id: user_id, is_registered: true]) do
        nil -> conn |> put_status(200) |> render(Spotlight.ErrorView, "error.json", %{title: "Not found", message: "Could not find user with the ID.", code: 404})
        user -> render(conn, "show_full.json", user: user)
      end
    else
      case Repo.get_by(User, [user_id: user_id, is_registered: true]) do
        nil -> conn |> put_status(200) |> render(Spotlight.ErrorView, "error.json", %{title: "Not found", message: "Could not find user with the ID.", code: 404})
        user -> render(conn, "show.json", user: user)
      end
    end
  end
end

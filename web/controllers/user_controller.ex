defmodule Spotlight.UserController do
  require Logger
  use Spotlight.Web, :controller

  alias Spotlight.User

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:update, :logout]

  def create(conn,
    %{"user" =>
      %{"name" => name,
        "email" => email,
        "password" => password,
        "country_code" => country_code,
        "phone" => mobile_number,
        "user_type" => user_type,
        "notification_token" => notification_token,
        "mobile_carrier" => mobile_carrier,
        "imei" => imei} }) do

    user = Repo.get_by(User, [email: email, is_registered: true])
    user_params = %{"phone" => mobile_number,
                    "country_code" => country_code,
                    "email" => email,
                    "name" => name,
                    "user_type" => user_type,
                    "imei" => imei,
                    "notification_token" => notification_token,
                    "mobile_carrier" => mobile_carrier}

    if(!is_nil(user)) do
      conn
        |> put_status(:ok)
        |> render(Spotlight.ErrorView, "error.json", %{title: "", message: "This email is already taken", code: 400})
    else
      #Stale user
      stale_user = Repo.get_by(User, [email: email])
      if(!is_nil(stale_user)) do
        Repo.delete(stale_user)
      end
      case user_type do
        "regular" -> :ok
        "official" -> :ok
        _ ->
          conn
            |> put_status(200)
            |>  render(Spotlight.ErrorView, "error.json", %{title: "", message: "Invalid user type.", code: 401})
        end

      changeset = User.create_changeset(%User{}, user_params)

      case Repo.insert(changeset) do
        {:ok, user_insert} ->
          created_user = Repo.get_by(User, [email: email])
          username =
            case user_type do
              "regular" -> "u_"<>Integer.to_string(created_user.id)
              "official" -> "o_"<>Integer.to_string(created_user.id)
              _ -> ""
            end

          register_user_changes  =  %{"is_registered" => true, "username" => username, "user_type" => user_type}
          register_changeset = Spotlight.User.register_changeset(created_user, register_user_changes)

          case Repo.update(register_changeset) do
            {:ok, updated_user} ->
              new_conn = Guardian.Plug.api_sign_in(conn, created_user)
              jwt = Guardian.Plug.current_token(new_conn)
              {:ok, %{"exp" => exp}} = Guardian.Plug.claims(new_conn)

              host = Application.get_env(:spotlight_api, Spotlight.Endpoint)[:url][:host]
              case :ejabberd_auth.set_password(username, host, password) do
                :ok ->
                  new_conn
                    |> put_status(:ok)
                    |> put_resp_header("authorization", "Bearer "<>jwt)
                    |> put_resp_header("x-expires", to_string(exp))
                    |> render("verified_token.json", %{user: updated_user, access_token: "Bearer "<>jwt, exp: to_string(exp)})
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
          |> render("verified_token.json", %{user: user, access_token: "Bearer "<>jwt, exp: to_string(exp)})
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
          |> render("verified_token.json", %{user: user, access_token: "Bearer "<>jwt, exp: to_string(exp)})
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
      {:ok, user} ->
        conn
          |> put_status(:ok)
          |> render("status.json", %{message: "Logged out successfully.", status: "success"})
      {:error, changeset} ->
        conn
          |> put_status(:ok)
          |> render(Spotlight.ErrorView, "error.json", %{title: "Error", message: "Error logging out.", code: 400})
    end
  end

  def show(conn, %{"username" => username}) do
    case Repo.get_by(User, [username: username, is_registered: true]) do
      nil -> conn |> put_status(404) |> render(Spotlight.ErrorView, "error.json", %{title: "Not found", message: "Could not find user with the ID.", code: 422})
      user -> render(conn, "show.json", user: user)
    end
  end

  def show(conn, %{"user_id" => user_id}) do
    case Repo.get_by(User, [user_id: user_id, is_registered: true]) do
      nil -> conn |> put_status(404) |> render(Spotlight.ErrorView, "error.json", %{title: "Not found", message: "Could not find user with the ID.", code: 422})
      user -> render(conn, "show.json", user: user)
    end
  end
end

defmodule Spotlight.UserController do
  require Logger
  use Spotlight.Web, :controller

  alias Spotlight.User

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:update]

  def create(conn, 
    %{"user" => 
      %{"name" => name, 
        "email" => email, 
        "password" => password, 
        "country_code" => country_code, 
        "phone" => mobile_number,
        "user_type" => user_type} }) do
        
    user = Repo.get_by(User, [email: email, is_registered: true])
    if(!is_nil(user)) do
      conn
        |> put_status(200)
        |> render("error.json", %{message: "User already exists.", code: 422})
      else
        user_params = %{"phone" => mobile_number,
                        "country_code" => country_code,
                        "email" => email,
                        "name" => name,
                        "user_type" => user_type}

        case user_type do
          "regular" -> :ok
          "official" -> :ok
          _ ->             
            conn
              |> put_status(200)
              |>  render("error.json", %{message: "Invalid user type.", code: 401})
          end

        changeset = User.create_changeset(%User{}, user_params)

        case Repo.insert(changeset) do
          {_, _} ->
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
                      |> put_status(200)
                      |> put_resp_header("authorization", "Bearer "<>jwt)
                      |> put_resp_header("x-expires", to_string(exp))
                      |> render("verified_token.json", %{user: updated_user, access_token: "Bearer "<>jwt, exp: to_string(exp)})
                  _ ->
                    conn
                      |> put_status(:unprocessable_entity)
                      |> render("error.json", %{message: "Could not create user.", code: 422})                    
                end
              {:error, _reason} ->
                conn
                  |> put_status(:unprocessable_entity)
                  |> render("error.json", %{message: "No user found", code: 422})
            end
        end
    end
  end

  def login(conn, 
    %{"user" => 
      %{"email" => email, 
        "password" => password
        }}) do
    
    host = Application.get_env(:spotlight_api, Spotlight.Endpoint)[:url][:host]
    user = Repo.get_by(User, [email: email, is_registered: true])

    if(is_nil(user)) do
      conn
        |> put_status(200)
        |> render("error.json", %{message: "Could not find user.", code: 422})
    else
      if :ejabberd_auth.check_password(user.username, "", host, password) do
        new_conn = Guardian.Plug.api_sign_in(conn, user)
        jwt = Guardian.Plug.current_token(new_conn)
        {:ok, %{"exp" => exp}} = Guardian.Plug.claims(new_conn)

        new_conn
         |> put_status(:ok)
          |> put_resp_header("authorization", "Bearer "<>jwt)
          |> put_resp_header("x-expires", to_string(exp))
          |> render("verified_token.json", %{user: user, access_token: "Bearer "<>jwt, exp: to_string(exp)})
      else
        conn
          |> put_status(:ok)
          |> render("error.json", %{message: "Invalid password", code: 401})
      end
    end
  end

  def login(conn, 
    %{"user" => 
      %{"user_id" => user_id, 
        "password" => password
        }}) do

    host = Application.get_env(:spotlight_api, Spotlight.Endpoint)[:url][:host]
    user = Repo.get_by(User, [user_id: user_id, is_registered: true])

    if(is_nil(user)) do
      conn
        |> put_status(200)
        |> render("error.json", %{message: "Could not find user.", code: 422})
    else
      if :ejabberd_auth.check_password(user.username, "", host, password) do
        new_conn = Guardian.Plug.api_sign_in(conn, user)
        jwt = Guardian.Plug.current_token(new_conn)
        {:ok, %{"exp" => exp}} = Guardian.Plug.claims(new_conn)

        new_conn
          |> put_status(:ok)
          |> put_resp_header("authorization", "Bearer "<>jwt)
          |> put_resp_header("x-expires", to_string(exp))
          |> render("verified_token.json", %{user: user, access_token: "Bearer "<>jwt, exp: to_string(exp)})
        else
          conn
            |> put_status(:ok)
            |> render("error.json", %{message: "Invalid password", code: 401})
      end
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
        |> render(Spotlight.ChangesetView, "update_error.json", changeset: changeset)
    end
  end

  def update(conn, %{"profile_dp" => image_data}) do
    IO.inspect image_data
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

  def show(conn, %{"username" => username}) do
    case Repo.get_by(User, [username: username, is_registered: true]) do
      nil -> conn |> put_status(404) |> render("error.json", %{code: 404, message: "User not found"})
      user -> render(conn, "show.json", user: user)
    end
  end

  def show(conn, %{"user_id" => user_id}) do
    case Repo.get_by(User, [user_id: user_id, is_registered: true]) do
      nil -> conn |> put_status(404) |> render("error.json", %{code: 404, message: "User not found"})
      user -> render(conn, "show.json", user: user)
    end
  end
end
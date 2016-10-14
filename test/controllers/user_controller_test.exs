defmodule Spotlight.UserControllerTest do
  use Spotlight.ConnCase

  alias Spotlight.User
  @create_valid_attrs %{phone: "9999999999", country_code: "91"}
  @create_invalid_attrs %{phone: "999999", country_code: "9"}
  @verify_invalid_attrs %{phone: "9999999999", country_code: "91", verification_code: "999999"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :show, user)
    assert json_response(conn, 200)["data"] == %{"id" => user.id,
      "name" => user.name,
      "phone" => user.phone,
      "country_code" => user.country_code,
      "is_registered" => user.is_registered,
      "id" => user.id,
    }
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @create_valid_attrs
    assert json_response(conn, 201)["status"] == "success"
    assert Repo.get_by(User, @create_valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @create_invalid_attrs
    assert json_response(conn, 422)["error"] != %{}
  end

  test "fail verification when verification data invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :verify), user: @verify_invalid_attrs
    assert json_response(conn, 401)["error"] != %{}
  end

  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
  #   user = Repo.insert! %User{}
  #   conn = put conn, user_path(conn, :update, user), user: @create_valid_attrs
  #   assert json_response(conn, 200)["data"]["id"]
  #   assert Repo.get_by(User, @create_valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   user = Repo.insert! %User{}
  #   conn = put conn, user_path(conn, :update, user), user: @create_invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end
end

defmodule Spotlight.UserTest do
  use Spotlight.ModelCase

  alias Spotlight.User

  @valid_attrs %{country_code: "some content", name: "some content", phone: "some content", phone_formatted: "some content", verification_status: true, verification_uuid: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end

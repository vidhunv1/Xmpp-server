defmodule Spotlight.UserTest do
  use Spotlight.ModelCase

  alias Spotlight.User

  @create_valid_attrs %{phone: "9999999999", country_code: "91", phone_formatted: "919999999999"}
  @create_invalid_attrs %{phone: "999999", country_code: "9", phone_formatted: "9999"}

  test "changeset, create with valid attributes" do
    changeset = User.create_changeset(%User{}, @create_valid_attrs)
    assert changeset.valid?
  end

  test "changeset, create with invalid attributes" do
    changeset = User.create_changeset(%User{}, @create_invalid_attrs)
    refute changeset.valid?
  end
end

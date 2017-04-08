defmodule Spotlight.PaymentsController do
  use Spotlight.Web, :controller
  require Logger
  import Ecto.Query

  alias Spotlight.User
  alias Spotlight.PaymentsDetails

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:create]

  def create(conn, %{"amount" => amount,
                                    "product_info" => product_info,
                                    "user_id" => user_id}) do
    current_user = Guardian.Plug.current_resource(conn)

    if(!is_nil(current_user) && current_user.user_type == "official") do
      case Repo.get_by(User, [user_id: user_id, is_registered: true]) do
        nil -> conn |> put_status(404) |> render(Spotlight.ErrorView, "error.json", %{title: "Not found", message: "Could not find user with the ID.", code: 422})
        user ->
          txnid = current_user.user_id<>"."<>UUID.uuid1()
          params = %{"transaction_id" => txnid, "amount" => amount, "product_info" => product_info, "email" => user.email, "first_name" => user.name, "phone" => user.phone, "user_id" => user_id}
          changeset = Spotlight.PaymentsDetails.create_transaction(%PaymentsDetails{}, params)

          case Repo.insert(changeset) do
            {:ok, user_insert} ->
              conn
                |> put_status(:ok)
                |> render(Spotlight.PaymentsView, "create_transaction.json", %{transaction_id: txnid, status: "Transaction Request created."})
            {:error, changeset} ->
              IO.inspect changeset
              conn
                |> put_status(500)
                |>  render(Spotlight.ErrorView, "error.json", %{title: "Error Creating Transaction", message: "Unauthorized.", code: 500})
          end
        end
    else
      conn
        |> put_status(401)
        |>  render(Spotlight.ErrorView, "error.json", %{title: "Not allowed", message: "Unauthorized.", code: 401})
    end
  end

  def get(conn, %{"transaction_id" => txnid}) do
    case Repo.get_by(PaymentsDetails, [transaction_id: txnid]) do
      nil -> conn |> put_status(404) |> render(Spotlight.ErrorView, "error.json", %{title: "Not found", message: "Could not Transaction.", code: 422})
      pd ->
        hash_string = Application.get_env(:spotlight_api, :PAYMENT_KEY)<>"|"<>pd.transaction_id<>"|"<>inspect(pd.amount)<>"|"<>pd.product_info<>"|"<>pd.first_name<>"|"<>pd.email<>"|||||||||||"<>Application.get_env(:spotlight_api, :PAYMENT_SALT)
        conn
          |> put_status(200)
          |> render("show_details.html", %{payment_details: pd, hash_string: :crypto.hash(:sha512, hash_string) |> Base.encode16 |> String.downcase})
    end
  end

  def transaction(conn, %{"status" => status, "email" => email, "firstname" => firstname, "productinfo" => productinfo, "amount" => amount, "txnid" => txnid, "key" => key}) do
    IO.inspect status
    IO.inspect email
    IO.inspect firstname
    IO.inspect productinfo
    IO.inspect amount
    IO.inspect txnid
    IO.inspect key
    # Calculate and verify hash
    conn
      |> put_status(200)
      |> render("show_success.html", %{txnid: txnid, amount: amount})
  end
end

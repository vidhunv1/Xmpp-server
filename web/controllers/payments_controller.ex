defmodule Spotlight.PaymentsController do
  use Spotlight.Web, :controller
  require Logger
  import Ecto.Query

  alias Spotlight.User
  alias Spotlight.PaymentsDetails
  alias Spotlight.PaymentMerchantHash

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:create, :store_merchant_hash, :get_merchant_hash, :delete_merchant_hash]
  plug Plug.Parsers, parsers: [:urlencoded]
  plug :accepts, ["x-www-form-urlencoded"] when action in [:transaction]

  def create(conn, %{"amount" => amount,
                     "product_info" => product_info,
                     "user_id" => user_id,
                     "transaction_secret" => transaction_secret}) do
    current_user = Guardian.Plug.current_resource(conn)

    if(!is_nil(current_user) && current_user.user_type == "official") do
      case Repo.get_by(User, [user_id: user_id, is_registered: true]) do
        nil -> conn |> put_status(404) |> render(Spotlight.ErrorView, "error.json", %{title: "Not found", message: "Could not find user with the ID.", code: 422})
        user ->
          txnid = String.slice(UUID.uuid4(:hex), 0..15)
          params = %{"transaction_secret" => transaction_secret, "created_by_user_id" => current_user.user_id, "transaction_id" => txnid, "amount" => amount, "product_info" => product_info, "email" => "", "first_name" => user.name, "phone" => user.phone, "user_id" => user_id}
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
    case Repo.get_by(PaymentsDetails, [transaction_id: txnid, is_delivered: false]) do
      nil -> conn |> put_status(404) |> render(Spotlight.ErrorView, "error.json", %{title: "Not found", message: "Could not Transaction.", code: 422})
      pd ->
        hash_string = Application.get_env(:spotlight_api, :PAYMENT_KEY)<>"|"<>pd.transaction_id<>"|"<>inspect(pd.amount)<>"|"<>pd.product_info<>"|"<>pd.first_name<>"||||||||||||"<>Application.get_env(:spotlight_api, :PAYMENT_SALT)
        conn
          |> put_status(200)
          |> render("show_details.html", %{payment_details: pd, hash_string: :crypto.hash(:sha512, hash_string) |> Base.encode16 |> String.downcase, payment_key: Application.get_env(:spotlight_api, :PAYMENT_KEY)})
    end
  end

  def transaction(conn, %{"mihpayid" => mihpayid, "bank_ref_num" => payment_id,
    "error_Message" => error_message, "hash" => hash, "status" => status, "email" => email, "firstname" => firstname,
    "productinfo" => productinfo, "txnid" => txnid, "amount" => amount}) do
    # Calculate and verify hash
    hash_string = :crypto.hash(:sha512, Application.get_env(:spotlight_api, :PAYMENT_SALT)<>"|"<>status<>"|||||||||||"<>email<>"|"<>firstname<>"|"<>productinfo<>"|"<>amount<>"|"<>txnid<>"|"<>Application.get_env(:spotlight_api, :PAYMENT_KEY)) |> Base.encode16 |> String.downcase

    if(String.equivalent?(hash_string, hash)) do
      Logger.info "Correct hash value"

      payment = Repo.get_by(PaymentsDetails, [transaction_id: txnid])

      case payment do
        nil -> conn |> put_status(422) |> render(Spotlight.ErrorView, "error.json", %{title: "Not found", message: "Could not find Transaction.", code: 422})
        pd ->
          bot_user = Repo.get_by(User, [user_id: pd.created_by_user_id]) |> Repo.preload([:bot_details])
          case BotHelper.send_on_transaction(pd.user_id,txnid,pd.transaction_secret,pd.amount,status,productinfo,bot_user.bot_details.post_url) do
            {:ok, _} ->
              #Message Delivered
              Logger.info("Delivered Transaction to #{bot_user.bot_details.post_url}.")
              changeset = PaymentsDetails.update_transaction(payment, %{"mihpayid" => mihpayid, "payment_id" => payment_id, "error_message" => error_message, "status" => status, "is_delivered" => true})
              Repo.update(changeset)
              case status do
                "success" ->
                  conn
                    |> put_status(200)
                    |> render("show_success.html", %{txnid: txnid, amount: pd.amount})
                "failure" ->
                  conn
                    |> put_status(200)
                    |> render("show_failure.html", %{txnid: txnid, amount: pd.amount})
              end
            {:error, m} ->
              #Error sending message
              Logger.debug("Error Posting transaction to #{bot_user.bot_details.post_url}. #{m}")
              changeset = PaymentsDetails.update_transaction(payment, %{"mihpayid" => mihpayid, "payment_id" => payment_id, "error_message" => error_message, "status" => status, "is_delivered" => false})
              Repo.update(changeset)
              conn |> put_status(404) |> render(Spotlight.ErrorView, "error.json", %{title: "Error ", message: "Error forwarding message.", code: 422})
          end
      end
    else
      Logger.info "Invalid hash value"
      send_resp(conn, 401, "Invalid hash value")
    end
  end

  def store_merchant_hash(conn, %{"merchant_hash" => merchant_hash_params}) do
    changeset = PaymentMerchantHash.changeset(%PaymentMerchantHash{}, merchant_hash_params)
    case Repo.insert(changeset) do
      {:ok, hash} ->
        conn
        |> put_status(:created)
        |> render(Spotlight.AppView, "status.json", %{message: "Merchant Hash updated", status: "success"})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def get_merchant_hash(conn, %{"merchant_key" => merchant_key, "user_credentials" => user_credentials}) do
    q = from(p in PaymentMerchantHash, where: p.merchant_key == ^merchant_key and p.user_credentials == ^user_credentials)
    conn |> put_status(200) |> render("show_merchant_hashes.json", payment_merchant_hashes: Repo.all(q))
  end

  def delete_merchant_hash(conn, %{"card_token" => card_token}) do
    Repo.get_by(PaymentMerchantHash, [card_token: card_token]) |> Repo.delete
    conn
    |> put_status(:ok)
    |> render(Spotlight.AppView, "status.json", %{message: "merchant hash deleted", status: "success"})
  end
end

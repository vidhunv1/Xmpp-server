defmodule Spotlight.PaymentsController do
  use Spotlight.Web, :controller
  require Logger
  import Ecto.Query

  alias Spotlight.User
  alias Spotlight.PaymentsDetails
  alias Spotlight.PaymentMerchantHash

  plug Guardian.Plug.EnsureAuthenticated, [handler: Spotlight.GuardianErrorHandler] when action in [:create, :store_merchant_hash, :get_merchant_hash, :delete_merchant_hash, :get_payment_hash, :put_merchant_hash, :get_merchant_hash_by_id]
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
    user = Guardian.Plug.current_resource(conn)

    check = Repo.get_by(PaymentMerchantHash, [card_token: merchant_hash_params["card_token"], merchant_hash: merchant_hash_params["merchant_hash"], merchant_key: merchant_hash_params["merchant_key"], user_credentials: merchant_hash_params["user_credentials"], user_id: user.id])
    if(!is_nil(check)) do
      conn
        |> put_status(:ok)
        |> render(Spotlight.AppView, "status.json", %{message: "Merchant Hash updated", status: "success"})
    else
      changeset = user |> Ecto.build_assoc(:payment_merchant_hashes) |> PaymentMerchantHash.changeset(merchant_hash_params)
      case Repo.insert(changeset) do
        {:ok, h} ->
          conn
          |> put_status(:created)
          conn |> put_status(200) |> render("show_merchant_hashes.json", payment_merchant_hashes: [h])
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
      end
    end
  end

  def get_merchant_hash(conn, %{"merchant_key" => merchant_key}) do
    user = Guardian.Plug.current_resource(conn)

    q = from(p in PaymentMerchantHash, where: p.merchant_key == ^merchant_key and p.user_id == ^user.id)
    conn |> put_status(200) |> render("show_merchant_hashes.json", payment_merchant_hashes: Repo.all(q))
  end

  def get_merchant_hash_by_id(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    q = from(p in PaymentMerchantHash, where: p.id == ^id and p.user_id == ^user.id)
    conn |> put_status(200) |> render("show_merchant_hashes.json", payment_merchant_hashes: Repo.all(q))
  end

  def put_merchant_hash(conn, %{"merchant_hash" =>
    %{
      "merchant_key" => merchant_key,
      "card_token" => card_token,
      "merchant_hash" => merchant_hash,
      "card_number_masked" => card_number_masked,
      "card_type" => card_type
    }}) do
    user = Guardian.Plug.current_resource(conn)

    changes = %{"card_number_masked" => card_number_masked, "card_type" => card_type}
    payment_merchant_hash = Repo.get_by(PaymentMerchantHash, [card_token: card_token, merchant_hash: merchant_hash, merchant_key: merchant_key, user_id: user.id])
    changeset = payment_merchant_hash |> PaymentMerchantHash.update_changeset(changes)

    case Repo.update(changeset) do
      {:ok, h} ->
        conn |> put_status(200) |> render("show_merchant_hashes.json", payment_merchant_hashes: [h])
      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> render(Spotlight.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete_merchant_hash(conn, %{"card_token" => card_token}) do
    user = Guardian.Plug.current_resource(conn)
    Repo.get_by(PaymentMerchantHash, [card_token: card_token, user_id: user.id]) |> Repo.delete
    conn
    |> put_status(:ok)
    |> render(Spotlight.AppView, "status.json", %{message: "merchant hash deleted", status: "success"})
  end

  def get_payment_hash(conn,
    %{"amount" => amount,
      "txnid" => txnid,
      "product_info" => product_info,
      "udf1" => udf1,
      "udf2" => udf2,
      "udf3" => udf3,
      "udf4" => udf4,
      "udf5" => udf5 }) do
    user = Guardian.Plug.current_resource(conn)

    key = Application.get_env(:spotlight_api, :PAYMENT_KEY)
    salt = Application.get_env(:spotlight_api, :PAYMENT_SALT)
    user_credentials = Application.get_env(:spotlight_api, :PAYMENT_KEY)<>":"<>user.country_code<>user.phone

    #payment_hash
    payment_hash_string = key<>"|"<>txnid<>"|"<>amount<>"|"<>product_info<>"|"<>user.name<>"|"<>user.country_code<>user.phone<>"@mobile.com|"<>udf1<>"|"<>udf2<>"|"<>udf3<>"|"<>udf4<>"|"<>udf5<>"||||||"<>salt
    payment_hash = Base.encode16(:crypto.hash(:sha512, payment_hash_string), case: :lower)

    #vas_for_mobile_sdk_hash
    vas_for_mobile_sdk_hash_string = key<>"|vas_for_mobile_sdk|default|"<>salt
    vas_for_mobile_sdk_hash = Base.encode16(:crypto.hash(:sha512, vas_for_mobile_sdk_hash_string), case: :lower)

    #payment_related_details_for_mobile_sdk_hash
    payment_related_details_for_mobile_sdk_hash_string = key<>"|payment_related_details_for_mobile_sdk|"<>user_credentials<>"|"<>salt
    payment_related_details_for_mobile_sdk_hash = Base.encode16(:crypto.hash(:sha512, payment_related_details_for_mobile_sdk_hash_string), case: :lower)

    #delete_user_card_hash
    delete_user_card_hash_string = key<>"|delete_user_card|"<>user_credentials<>"|"<>salt
    delete_user_card_hash = Base.encode16(:crypto.hash(:sha512, delete_user_card_hash_string), case: :lower)

    #get_user_cards_hash
    get_user_cards_hash_string = key<>"|get_user_cards|"<>user_credentials<>"|"<>salt
    get_user_cards_hash = Base.encode16(:crypto.hash(:sha512, get_user_cards_hash_string), case: :lower)

    #edit_user_card_hash
    edit_user_card_hash_string = key<>"|edit_user_card|"<>user_credentials<>"|"<>salt
    edit_user_card_hash = Base.encode16(:crypto.hash(:sha512, edit_user_card_hash_string), case: :lower)

    #save_user_card_hash
    save_user_card_hash_string = key<>"|save_user_card|"<>user_credentials<>"|"<>salt
    save_user_card_hash = Base.encode16(:crypto.hash(:sha512, save_user_card_hash_string), case: :lower)

    hashes = %{
    payment_hash: payment_hash,
    vas_for_mobile_sdk_hash: vas_for_mobile_sdk_hash,
    payment_related_details_for_mobile_sdk_hash: payment_related_details_for_mobile_sdk_hash,
    delete_user_card_hash: delete_user_card_hash,
    get_user_cards_hash: get_user_cards_hash,
    edit_user_card_hash: edit_user_card_hash,
    save_user_card_hash: save_user_card_hash,
    first_name: user.name,
    user_credentials: user_credentials,
    key: key,
    phone: user.country_code<>user.phone,
    email: user.country_code<>user.phone<>"@mobile.com"}

    conn
      |> put_status(:ok)
      |> render("hashes.json", hashes)
  end
end
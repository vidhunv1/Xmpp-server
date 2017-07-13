defmodule Spotlight.PaymentsView do
  use Spotlight.Web, :view

  def render("create_transaction.json", %{transaction_id: transaction_id, status: status}) do
    %{transaction_id: transaction_id,
      status: status}
  end

  def render("transaction.json", %{transaction_id: transaction_id, status: status, user_id: user_id, productinfo: productinfo, amount: amount}) do
     %{transaction_id: transaction_id,
        status: status,
        user_id: user_id,
        productinfo: productinfo,
        amount: amount}
  end

  def render("show_merchant_hashes.json", %{payment_merchant_hashes: hashes}) do
    %{merchant_hashes: render_many(hashes, Spotlight.PaymentsView, "show_merchant_hash.json")}
  end

  def render("show_merchant_hash.json", %{payments: hash}) do
    %{card_token: hash.card_token, merchant_hash: hash.merchant_hash}
  end

  def render("hashes.json", %{
    payment_hash: payment_hash,
    vas_for_mobile_sdk_hash: vas_for_mobile_sdk_hash,
    payment_related_details_for_mobile_sdk_hash: payment_related_details_for_mobile_sdk_hash,
    delete_user_card_hash: delete_user_card_hash,
    get_user_cards_hash: get_user_cards_hash,
    edit_user_card_hash: edit_user_card_hash,
    save_user_card_hash: save_user_card_hash,
    first_name: first_name,
    user_credentials: user_credentials,
    phone: phone,
    email: email}) do

    %{
      payment_hash: payment_hash,
      vas_for_mobile_sdk_hash: vas_for_mobile_sdk_hash,
      payment_related_details_for_mobile_sdk_hash: payment_related_details_for_mobile_sdk_hash,
      delete_user_card_hash: delete_user_card_hash,
      get_user_cards_hash: get_user_cards_hash,
      edit_user_card_hash: edit_user_card_hash,
      save_user_card_hash: save_user_card_hash,
      first_name: first_name,
      user_credentials: user_credentials,
      phone: phone,
      email: email
    }

  end
end

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
end

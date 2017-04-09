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
end

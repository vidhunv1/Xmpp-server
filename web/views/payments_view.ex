defmodule Spotlight.PaymentsView do
  use Spotlight.Web, :view

  def render("create_transaction.json", %{transaction_id: transaction_id, status: status}) do
    %{transaction_id: transaction_id,
      status: status}
  end
end

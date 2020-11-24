class AddTitleToPaymentRows < ActiveRecord::Migration
  def change
    add_column :payment_rows, :title, :string
  end
end

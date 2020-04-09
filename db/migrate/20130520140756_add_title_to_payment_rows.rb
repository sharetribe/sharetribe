class AddTitleToPaymentRows < ActiveRecord::Migration[5.2]
def change
    add_column :payment_rows, :title, :string
  end
end

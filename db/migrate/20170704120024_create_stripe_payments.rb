class CreateStripePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :stripe_payments do |t|
      t.integer   :community_id
      t.integer   :transaction_id
      t.string    :payer_id
      t.string    :receiver_id
      t.string    :status
      t.integer   :sum_cents
      t.integer   :commission_cents
      t.string    :currency
      t.string    :stripe_charge_id
      t.string    :stripe_transfer_id
      t.datetime  :transfered_at

      t.timestamps
    end
  end
end

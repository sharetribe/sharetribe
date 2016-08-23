class RemoveOldPaymentColumnsFromCommunity < ActiveRecord::Migration
  def change
    remove_column :communities, :commission_from_seller, :integer, after: :vat
    remove_column :communities, :vat, :integer, after: :facebook_connect_enabled
    remove_column :communities, :testimonials_in_use, :boolean, after: :minimum_price_cents, default: true
  end
end

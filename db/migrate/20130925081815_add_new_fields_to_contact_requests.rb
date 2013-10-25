class AddNewFieldsToContactRequests < ActiveRecord::Migration
  def change
    add_column :contact_requests, :country, :string
    add_column :contact_requests, :plan_type, :string
    add_column :contact_requests, :marketplace_type, :string
  end
end

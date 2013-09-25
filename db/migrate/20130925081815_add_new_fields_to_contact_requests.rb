class AddNewFieldsToContactRequests < ActiveRecord::Migration
  def change
    add_column :contact_requests, :country, :string
    add_column :contact_requests, :free_plan, :boolean
    add_column :contact_requests, :paid_plan, :boolean
    add_column :contact_requests, :marketplace_type, :string
  end
end

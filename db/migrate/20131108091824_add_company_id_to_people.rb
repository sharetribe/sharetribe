class AddCompanyIdToPeople < ActiveRecord::Migration
  def change
    add_column :people, :company_id, :string
  end
end

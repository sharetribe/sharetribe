class AddStatusToPersonBgcheck < ActiveRecord::Migration
  def change
  	add_column :person_background_checks, :status_ids, :text
  end
end

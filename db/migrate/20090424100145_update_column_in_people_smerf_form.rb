class UpdateColumnInPeopleSmerfForm < ActiveRecord::Migration
  def self.up
    change_column :people_smerf_forms, :person_id, :string
  end

  def self.down
    change_column :people_smerf_forms, :person_id, :int
  end
end

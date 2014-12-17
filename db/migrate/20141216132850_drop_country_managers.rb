class DropCountryManagers < ActiveRecord::Migration
  def up
    drop_table :country_managers
  end

  def down
    create_table "country_managers" do |t|
      t.string   "given_name"
      t.string   "family_name"
      t.string   "email"
      t.string   "country"
      t.string   "locale"
      t.datetime "created_at",    :null => false
      t.datetime "updated_at",    :null => false
      t.string   "subject_line"
      t.text     "email_content"
    end
  end
end

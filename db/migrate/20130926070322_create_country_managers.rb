class CreateCountryManagers < ActiveRecord::Migration[5.2]
def change
    create_table :country_managers do |t|
      t.string :given_name
      t.string :family_name
      t.string :email
      t.string :country
      t.string :locale
      t.text :email_signature

      t.timestamps
    end
  end
end

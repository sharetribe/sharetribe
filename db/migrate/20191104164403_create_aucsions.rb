class CreateAucsions < ActiveRecord::Migration[5.2]
  def change
    create_table :aucsions do |t|
      t.references :listing
      t.string :person_id
      t.integer :price_aucsion_cents

      t.timestamps
    end
  end
end

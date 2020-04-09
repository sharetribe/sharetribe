class CreateCustomFields < ActiveRecord::Migration[5.2]
def change
    create_table :custom_fields do |t|
      t.string :type

      t.timestamps
    end
  end
end

class CreateCustomFieldOptionTitles < ActiveRecord::Migration
  def change
    create_table :custom_field_option_titles do |t|
      t.string :value
      t.string :locale
      t.belongs_to :custom_field_option

      t.timestamps
    end
  end
end

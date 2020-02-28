class CreateDomainSetups < ActiveRecord::Migration[5.2]
  def change
    create_table :domain_setups do |t|
      t.references :community, index: { unique: true }
      t.string :domain, null: false
      t.string :state, null: false
      t.string :error
      t.boolean :critical_error

      t.timestamps
    end

    add_index :domain_setups, [:state, :updated_at]
    add_index :domain_setups, :critical_error
  end
end

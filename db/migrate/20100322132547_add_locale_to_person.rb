class AddLocaleToPerson < ActiveRecord::Migration[5.2]
def self.up
    add_column :people, :locale, :string, :default => "fi"
  end

  def self.down
    remove_column :people, :locale
  end
end

class AddAuthenticationTokenToPeople < ActiveRecord::Migration[5.2]
def self.up
    add_column :people, :authentication_token, :string
  end

  def self.down
    remove_column :people, :authentication_token
  end
end

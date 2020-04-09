class RemoveTimesUsedFromAuthenticationToken < ActiveRecord::Migration[5.2]
def up
    remove_column :auth_tokens, :times_used
  end

  def down
    add_column :auth_tokens, :times_used, :integer, default: 0
  end
end

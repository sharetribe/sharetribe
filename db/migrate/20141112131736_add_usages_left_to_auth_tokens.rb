class AddUsagesLeftToAuthTokens < ActiveRecord::Migration
  def change
    add_column :auth_tokens, :usages_left, :integer, :after => :expires_at
  end
end

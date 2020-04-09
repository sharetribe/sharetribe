class AddAllowLoginToAuthTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :auth_tokens, :token_type, :string, :after => :token, :default => "unsubscribe"
  end
end

class AddUseCaptchaToCommunities < ActiveRecord::Migration[5.2]
def self.up
    add_column :communities, :use_captcha, :boolean, :default => true
  end

  def self.down
    remove_column :communities, :use_captcha
  end
end

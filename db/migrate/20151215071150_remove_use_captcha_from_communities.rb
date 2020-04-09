class RemoveUseCaptchaFromCommunities < ActiveRecord::Migration[5.2]
def up
    remove_column :communities, :use_captcha
  end

  def down
    add_column :communities, :use_captcha, :boolean, default: false, after: :join_with_invite_only
  end
end

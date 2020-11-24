class AddEmailToFeedbacks < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :email, :string
  end

  def self.down
    remove_column :feedbacks, :email
  end
end

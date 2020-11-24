class ChangeContentFromStringToTextInNewsItems < ActiveRecord::Migration
  def self.up
    change_column :news_items, :content, :text
  end

  def self.down
    change_column :news_items, :content, :string
  end
end

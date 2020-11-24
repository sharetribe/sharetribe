class ConvertSerializedSettingsAndPreferences < ActiveRecord::Migration[5.1]
  def up
    Community.where("settings LIKE '%ActionController%'").find_each{|c| c.update_column(:settings, c.settings.to_unsafe_hash.to_hash)}
    Person.where("preferences LIKE '%ActionController%'").find_each{|p| p.update_column(:preferences, p.preferences.to_unsafe_hash)}
  end

  def down; end
end

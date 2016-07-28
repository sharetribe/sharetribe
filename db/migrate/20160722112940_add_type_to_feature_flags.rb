class AddTypeToFeatureFlags < ActiveRecord::Migration
  def change
    add_column :feature_flags, :type, :string
  end
end

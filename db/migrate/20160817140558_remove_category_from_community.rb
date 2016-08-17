class RemoveCategoryFromCommunity < ActiveRecord::Migration
  def change
    remove_column(:communities, :category, :string, default: "other", after: :description)
  end
end

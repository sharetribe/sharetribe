class RemoveCategoryFromCommunity < ActiveRecord::Migration[5.2]
def change
    remove_column(:communities, :category, :string, default: "other", after: :description)
  end
end

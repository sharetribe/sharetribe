class ChangeListingAuthorIdNotNull < ActiveRecord::Migration
  def change
    change_column_null :transactions, :listing_author_id, false
  end
end

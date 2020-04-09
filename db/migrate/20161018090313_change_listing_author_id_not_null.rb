class ChangeListingAuthorIdNotNull < ActiveRecord::Migration[5.2]
def change
    change_column_null :transactions, :listing_author_id, false
  end
end

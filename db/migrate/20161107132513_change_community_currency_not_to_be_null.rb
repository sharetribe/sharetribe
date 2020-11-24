class ChangeCommunityCurrencyNotToBeNull < ActiveRecord::Migration
  def change
    change_column_null :communities, :currency, false
  end
end

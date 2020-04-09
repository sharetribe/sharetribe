class ChangeCommunityCurrencyNotToBeNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :communities, :currency, false
  end
end

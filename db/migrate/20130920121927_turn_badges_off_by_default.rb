class TurnBadgesOffByDefault < ActiveRecord::Migration
  def up
    change_column_default :communities, :badges_in_use, 0
  end

  def down
    change_column_default :communities, :badges_in_use, 1
  end
end

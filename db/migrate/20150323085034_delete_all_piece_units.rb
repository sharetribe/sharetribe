class DeleteAllPieceUnits < ActiveRecord::Migration
  # At this point there should not be any unit_type: :piece rows
  # However, due to a bug in previous commits, there might be some. Remove them now.
  def up
    execute("DELETE FROM listing_units WHERE unit_type = 'piece'")
  end

  def down
    # nothing
  end
end

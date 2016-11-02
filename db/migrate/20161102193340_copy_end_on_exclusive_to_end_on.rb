class CopyEndOnExclusiveToEndOn < ActiveRecord::Migration
  def up
    name = "Copy end_on_exclusive to end_on"
    sql = "UPDATE bookings SET end_on = end_on_exclusive"

    exec_update(sql, name, [])
  end
end

class RemoveStatusFromBackgroundCheckContainers < ActiveRecord::Migration
  def change
    remove_column :background_check_containers, :status
    remove_column :background_check_containers, :status_bg_color
  end
end

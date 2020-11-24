class CreateExportTaskResults < ActiveRecord::Migration[4.2]
  def change
    create_table :export_task_results do |t|
      t.string :status
      t.string :token
      t.attachment :file

      t.timestamps null: false
    end
  end
end

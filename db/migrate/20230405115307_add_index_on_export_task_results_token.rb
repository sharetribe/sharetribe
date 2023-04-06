class AddIndexOnExportTaskResultsToken < ActiveRecord::Migration[6.1]
  def change
    add_index :export_task_results, [:token], name: 'index_on_token', unique: true
  end
end

class DropOldUnusedColumns < ActiveRecord::Migration
  def change
    remove_column :communities, :dv_test_file, :string, limit: 64, after: :dv_test_file_name
    remove_column :communities, :dv_test_file_name, :string, limit: 64, after: :favicon_processing
  end
end

class AddDvTestFileToCommunity < ActiveRecord::Migration[5.2]
def change
    add_column :communities, :dv_test_file_name, :string, after: :favicon_processing, limit: 64
    add_column :communities, :dv_test_file, :string, after: :dv_test_file_name, limit: 64
  end
end

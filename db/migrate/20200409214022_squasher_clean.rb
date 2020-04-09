class SquasherClean < ActiveRecord::Migration[5.2]
  class SchemaMigration < ActiveRecord::Base
  end

  def up
    migrations = Dir.glob(File.join(File.dirname(__FILE__), '*.rb'))
    versions = migrations.map { |file| File.basename(file)[/\A\d+/] }
    SchemaMigration.where("version NOT IN (?)", versions).delete_all
  end

  def down
  end
end

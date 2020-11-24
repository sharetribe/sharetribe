# db:structure:dump adds AUTO_INCREMENT to the structure.sql file
# AUTO_INCREMENT adds a lot of annoying diff noise and makes merging painful.
# Remove all the AUTO_INCREMENTs
#
# See: http://stackoverflow.com/questions/2210719/out-of-sync-auto-increment-values-in-development-structure-sql-from-rails-mysql
Rake::Task["db:structure:dump"].enhance do
  path = Rails.root.join('db', 'structure.sql')
  File.write path, File.read(path).gsub(/ AUTO_INCREMENT=\d*/, '')
end

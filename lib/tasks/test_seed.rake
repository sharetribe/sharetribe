# Load seeds to test.db after the test:prepare is done
# Credits to Eugene Bolshakov (http://stackoverflow.com/questions/1574797/how-to-load-dbseed-data-into-test-database-automatically/1998520#1998520)
namespace :db do
  namespace :test do
    task :prepare => :environment do
      Rake::Task["db:seed"].invoke
    end
  end
end

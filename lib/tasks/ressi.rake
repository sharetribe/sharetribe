namespace :ressi do
  desc "Uploads logging data to Ressi"
  task :upload => :environment do
    puts "Uploading #{CachedRessiEvent.count} events to Ressi"
    CachedRessiEvent.upload_all
  end
end

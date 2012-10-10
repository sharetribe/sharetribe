namespace :sharetribe do
  namespace :demo do
    
    
    desc "Reads the demo data from lib/demos and populates the database with that data"
    task :load, [:locale] => :environment do |t, args|
      require 'spreadsheet'
      
      spreadsheet = load_spreadsheet(args[:locale])
      puts "Aborting" and return if spreadsheet.nil?
      
      user_sheet = spreadsheet.worksheet "Users"
      
      user_sheet.each 1 do |row|
        if row[1].present?
          puts row[1]
          Person.create!(
                 :username => row[1],
                 :email =>    row[2],
                 :password => row[3],
                 :given_name => row[4],
                 :family_name => row[5],
                 :phone_number => row[6],
                 :description => row[7],
                 :confirmed_at=> Time.now
                 
          )
        end
      end
      
    end
    
    desc "removes the content created by the demoscript from the DB. It's based on usernames, so don't use if there's a risk of collisions."
    task :clear, [:locale] => :environment do |t, args|
      require 'spreadsheet'
      
      spreadsheet = load_spreadsheet(args[:locale])
      puts "Aborting" and return if spreadsheet.nil?
      
      user_sheet = spreadsheet.worksheet "Users"
      user_sheet.each 1 do |row|
        if row[1].present?
          Person.find_by_username(row[1]).destroy
        end
      end
    end
    
    def load_spreadsheet(locale)
      demo_data_path = "lib/demos/demo_data.#{locale}.xls"
      unless  File.exists?(demo_data_path)
        puts "Could not find #{demo_data_path}"
        return nil
      end
      Spreadsheet.open demo_data_path
    end
  end
end
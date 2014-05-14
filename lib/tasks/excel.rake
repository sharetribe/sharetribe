namespace :excel do
  # Load Config
  require File.expand_path('../../../config/config_loader', __FILE__)
  APP_CONFIG = ConfigLoader.load_app_config

  require 'spreadsheet'

  desc 'Creates communities out of an excel file with community names in one column and domains in another'
  task :import_okl => :environment do
    book = Spreadsheet.open 'communities/okl_associations.xls'
    sheet = book.worksheet 0
    sheet.each do |row|
      Community.create(:name => row[1], :domain => row[2], :settings => {"locales"=>["fi", "en"]}, :label => "okl")
    end
  end

end

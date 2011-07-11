namespace :i18n do
  
  APP_CONFIG = OpenStruct.new(YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env].symbolize_keys)
  
  def write_error_page(status, locale = nil)
    dest_filename = [status.to_s, locale, "html"].compact.join(".")
    File.open(File.join(Rails.root, "public", dest_filename), "w") do |file|
      path = File.join("app", "views", "errors", "#{status}.haml")
      file.print ActionView::Base.new(Rails.configuration.paths.app.views.first).render(:file => path)
    end   
  end
  
  desc 'Write public/404.html and public/500.html error pages'
  task :write_error_pages => :environment do
    [404, 500].each do |status|
      APP_CONFIG.available_locales.collect{|loc| loc[1]}.each do |locale|
        I18n.with_locale locale do
          write_error_page(status, locale)
          # Create also a default error page for situations
          # when error pages are not run through rails
          write_error_page(status) if locale.eql?("en")
        end
      end
    end
  end
  
end
class ErrorMailer < ActionMailer::Base

  def snapshot(exception, trace, session, params, request, current_user, sent_on = Time.now)

    content_type "text/html"
  
    recipients  APP_CONFIG.error_mailer_recipients
    from        APP_CONFIG.error_mailer_from_address
    subject     "[Error] exception on #{APP_CONFIG.production_server} in #{request.request_uri}"
    sent_on    sent_on
    body        :exception => exception, :trace => trace,
                :session => session, :params => params, 
                :request => request, :current_user => current_user
    
  end

end
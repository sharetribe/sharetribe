class ErrorMailer < ActionMailer::Base

  def snapshot(exception, trace, session, params, request, current_user, sent_on = Time.now)

    content_type "text/html"
  
    recipients  'juho.makkonen@tkk.fi, gnomet@gmail.com'
    from        'Error Mailer <KassiErrors@sizl.org>'
    subject     "[Error] exception on #{PRODUCTION_SERVER} in #{request.request_uri}"
    sent_on    sent_on
    body        :exception => exception, :trace => trace,
                :session => session, :params => params, 
                :request => request, :current_user => current_user
    
  end

end
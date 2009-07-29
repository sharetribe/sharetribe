class ErrorMailer < ActionMailer::Base

 def snapshot(exception, trace, session, params, env, sent_on = Time.now)

  # [nazgum]: Setting the content-type like this did not work for me
  #@headers["Content-Type"] = "text/html"

  # Setting the content-type like this does:
  content_type "text/html"

  @recipients   = 'gnomet@gmail.com'
  @from     = 'Error Mailer <error @ domain.tld>'
  @subject    = "[Error] exception in #{env['REQUEST_URI']}"
  @sent_on    = sent_on
  @body["exception"] = exception
  @body["trace"]  = trace
  @body["session"]  = session
  @body["params"]  = params
  @body["env"]   = env
 end

end
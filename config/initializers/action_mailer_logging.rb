class ActionMailerLogger
  def self.delivering_email(message)
    logger.info("Delivering email",
                :delivering_email,
                to: message.to,
                from: message.from,
                subject: message.subject)
  end

  def self.logger
   @logger ||= SharetribeLogger.new(:action_mailer)
 end
end

ActionMailer::Base.register_interceptor(ActionMailerLogger)

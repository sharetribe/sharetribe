class HandlePaypalIpnMessageJob < Struct.new(:msg_id)

  include DelayedAirbrakeNotification
  include PaypalService::IPNInjector

  #omit before-method as this job doesn't require current community, as paypal ipns are handled outside communities

  IPNDataTypes = PaypalService::DataTypes::IPN

  def perform
    logger = PaypalService::Logger.new
    raw_msg = PaypalIpnMessage.find(msg_id)

    begin
      ipn_msg = IPNDataTypes.from_params(raw_msg.body)

      if(ipn_msg[:type] == :unknown)
        logger.warn("Unknown IPN message type: #{raw_msg.body}")
        raw_msg.update_attribute(:status, :unknown)
      else
        ipn_service.handle_msg(ipn_msg)
        raw_msg.update_attribute(:status, :success)
      end

    rescue => e
      raw_msg.update_attribute(:status, :errored)
      raise e #raise the exception ahead for airbrake reporting
    end

  end
end

require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class PopulatePaymentGatewayToPayment < ActiveRecord::Migration
  include LoggingHelper

  def up
    Payment.find_each do |payment|
      begin
        payment.update_attribute(:payment_gateway_id, payment.community.payment_gateway.id)
        print_dot
      rescue
        puts "failed. payment: #{Maybe(payment).id.or_else("nil payment")}, payment_gateway: #{Maybe(payment).community.payment_gateway.or_else("no gateway")}"
      end
    end
  end

  def down
    Payment.update_all payment_gateway_id: nil
  end
end

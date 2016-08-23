class ChangeBraintreePreauthorizationProcessesToFree < ActiveRecord::Migration
  def up
    # Change all preauthorize processes to none unless they are in use with Paypal gateway
    execute "UPDATE transaction_processes tp
             SET tp.process = 'none'
             WHERE tp.process = 'preauthorize' AND (
               SELECT COUNT(*) = 0
               FROM payment_settings ps
               WHERE ps.community_id = tp.community_id AND
                     ps.active = 1 AND
                     ps.payment_process = 'preauthorize'
             )"
  end

  def down
    execute "UPDATE transaction_processes SET process = old_process WHERE old_process = 'preauthorize'"
  end
end

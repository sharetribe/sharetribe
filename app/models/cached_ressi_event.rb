# == Schema Information
#
# Table name: cached_ressi_events
#
#  id                :integer          not null, primary key
#  user_id           :string(255)
#  application_id    :string(255)
#  session_id        :string(255)
#  ip_address        :string(255)
#  action            :string(255)
#  parameters        :text
#  return_value      :string(255)
#  headers           :text
#  semantic_event_id :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  test_group_number :integer
#  community_id      :integer
#

require 'timeout'

class CachedRessiEvent < ActiveRecord::Base

  def CachedRessiEvent.upload_all
    if CachedRessiEvent.count > 0
      logger.info "Uploading #{CachedRessiEvent.count} events to Ressi at #{Time.now}.\n"

      CachedRessiEvent.find_in_batches(:batch_size => 1000) do |events|
        events.each_with_index do |event, i|
          tries = 0
          begin
            tries += 1
            event.upload
            event.destroy
          rescue => e
            if tries < 5
              logger.info "Retrying..."
              retry
            end
            raise e
          end
        end
      end
      logger.info "Ressi upload finished at #{Time.now}.\n"
    end
  end

  def upload

    event = RessiEvent.create({
                              :user_id =>        user_id,
                              :application_id => application_id,
                              :session_id =>     session_id,
                              :ip_address =>     ip_address,
                              :action =>         action,
                              :parameters =>     parameters,
                              :return_value =>   return_value,
                              :headers =>        headers,
                              :semantic_event_id => semantic_event_id,
                              :created_at =>     created_at,
                              :test_group_number  => test_group_number
                            })
  end
end

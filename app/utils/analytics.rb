# Analytics module encapsulates passing information from controllers
# to analytics implementations. Analytics scripts are added to page as
# part of view rendering. Information from controllers is passed to
# scripts in a standard format using the flash-object as a carrier.
#
# ==== Usage
#
# To record an event when you issue a normal render pass in `flash.now`:
#   Analytics.record_event(flash.now, "Event name", { marketplace_uuid: @current_community.uuid_object.to_s })
#
# To record an event on page load after redirect pass in `flash`:
#   Analytics.record_event(flash, "Event name", { marketplace_uuid: @current_community.uuid_object.to_s })
#
# To clear the user identification data (at log out):
#  Analytics.mark_logged_out(flash)
#
module Analytics

  EVENT_KEY = :_analytics_event
  LOGOUT_KEY = :_analytics_logout

  module_function

  def record_event(flash_or_now, event_name, props)
    flash_or_now[EVENT_KEY] = {
      event: event_name,
      props: props
    }
  end

  def mark_logged_out(flash_or_now)
    flash_or_now[LOGOUT_KEY] = true
  end
end

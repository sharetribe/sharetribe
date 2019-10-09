module RefererHider
  extend ActiveSupport::Concern

  HIDE_REFERER_ON = [
    {controller: 'passwords', action: 'edit'}
  ].freeze

  included do
    before_action :set_hide_referer
  end

  def set_hide_referer
    HIDE_REFERER_ON.each do |item|
      if controller_name == item[:controller] && action_name == item[:action]
        force_hide_referer
      end
    end
  end

  def force_hide_referer
    @hide_referer = true
    response.set_header('Referrer-Policy', 'no-referrer')
  end
end

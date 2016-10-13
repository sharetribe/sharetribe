module NotificationsHelper
  module_function

  def notifications(flash)
    return nil if RequestStore.store.key?(:notifications_displayed)

    RequestStore.store[:notifications_displayed] = true
    [:notice, :warning, :error].each_with_object({}) do |level, acc|
      if flash[level]
        acc[level] = flash[level]
      end
    end.compact
  end
end

module NotificationsHelper
  module_function

  def notifications(flash)
    return nil if RequestStore.store.key?(:notifications_displayed)

    RequestStore.store[:notifications_displayed] = true
    [:notice, :warning, :error].reduce(Hash.new) do |acc, level|
      if flash[level]
        acc[level] = flash[level]
      end
      acc
    end.compact
  end
end

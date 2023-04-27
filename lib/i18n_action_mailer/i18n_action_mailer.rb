module I18nActionMailer

  def self.included(base)
    base.send :include, I18nActionMailer::InstanceMethods
    base.helper_method :locale, :t, :translate, :l, :localize
  end

  module InstanceMethods
    def translate(key, **kwargs)
      I18n.translate(key, **kwargs)
    end
    alias_method :t, :translate

    def localize(key, **kwargs)
      I18n.localize(key, **kwargs)
    end
    alias_method :l, :localize
  end
end

ActionMailer::Base.send(:include, I18nActionMailer)

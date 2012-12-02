module I18nActionMailer

  def self.included(base)
    base.send :include, I18nActionMailer::InstanceMethods
    base.helper_method :locale, :t, :translate, :l, :localize
  end

  module InstanceMethods
    def translate(key, options = {})
      I18n.translate(key, options.merge(:locale => self.locale))
    end
    alias_method :t, :translate

    def localize(key, options = {})
      I18n.localize(key, options.merge(:locale => self.locale))
    end
    alias_method :l, :localize

    def locale
      @locale
    end

    def set_locale(locale)
      @locale = locale
    end
  end

end

ActionMailer::Base.send(:include, I18nActionMailer)
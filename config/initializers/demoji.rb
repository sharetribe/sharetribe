require 'active_support/concern'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/object/blank'

module Demoji
  def create_or_update *args
    _rescued_counter ||= 0

    ActiveSupport::Deprecation.silence { super }
  rescue ActiveRecord::StatementInvalid => ex
    raise ex unless ex.message.match /Mysql2::Error: Incorrect string value:/

    _rescued_counter += 1

    raise ex if _rescued_counter > 1

    _fix_utf8_attributes
    retry
  end

  def _fix_utf8_attributes
    self.attributes.each do |k, v|
      next if v.blank? || !v.is_a?(String)
      self.send "#{k}=", _fix_chars(v)
    end
  end

  def _fix_chars(str)
    "".tap do |out_str|

      # for instead of split and joins for perf
      for i in (0...str.length)
        char = str[i]
        char = 32.chr if char.ord > 65535
        out_str << char
      end

    end
  end
end

ActiveRecord::Base.send :include, Demoji

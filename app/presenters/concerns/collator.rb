module Collator
  extend ActiveSupport::Concern

  # using proper collation to correctly sort in other languaged
  def collator
    lang = I18n.locale.to_s.downcase.split("-").first
    if TwitterCldr.supported_locale?(I18n.locale)
      TwitterCldr::Collation::Collator.new(I18n.locale)
    elsif TwitterCldr.supported_locale?(lang)
      TwitterCldr::Collation::Collator.new(lang)
    else
      TwitterCldr::Collation::Collator.new
    end
  end
end

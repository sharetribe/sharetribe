module TranslationHelper
  class NewTranslationOrFallback

    def initialize(new_translation = nil)
      @new_translation = new_translation
    end

    def or_fallback_to(tr_key, opts = {})
      @new_translation || I18n.translate(tr_key, opts)
    end
  end

  # Uses translations key or a fallback, if the first given key is translated in the current language
  #
  # Usage:
  #
  # # yml:
  # build_a_vehicle_with_four_wheels: Build a vehicle with four wheels.
  # build_a_car: Build a car.
  # build_a_vehicle_that_flies: Build a vehicle that flies.
  # build_an_airplane: ~
  # count_apples: "There are #{count} appels"
  # apples:
  #   one: "#{count} apple"
  #   other:
  #
  # # haml:
  #
  # use_new_translation("build_a_car").or_fallback_to("build_a_vehicle_with_four_wheels")
  # => "Build a car."
  #
  # use_new_translation("build_an_airplane").or_fallback_to("build_a_vehicle_that_flies")
  # => "Build a vehicle that flies."
  #
  # use_new_translation("apples", count: "1").or_fallback_to("count_apples", count: 1)
  # => "1 apple"
  #
  # use_new_translation("apples", count: "5").or_fallback_to("count_apples", count: 5)
  # => "There are 5 apples"
  #
  def use_new_translation(tr_key, opts = {})
    translation =
      I18n.translate(tr_key, opts.merge(
                       # Throw error, if not found
                       # Disable fallbacks (no idea why the value needs to be `true`
                       # instead of `false`. Feels counter intuitive)
                       throw: true,
                       fallback: true
                     ))

    NewTranslationOrFallback.new(translation)
  rescue StandardError
    NewTranslationOrFallback.new
  end
end

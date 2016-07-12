module ColorUtils

  module_function

  # Same as in filter: brightness(80%) in CSS
  #
  # Usage:
  #
  # brightness("80E619", 80) == "66B814"
  #
  def brightness(name_or_hex, percentage)
    # CSS brightness(80%) is the same as adjust_brightness(-20)
    p = percentage - 100

    Color::RGB
      .by_css(name_or_hex)
      .adjust_brightness(p)
      .hex
      .upcase
  end

  # Same as darken(color, percentage) is SASS
  #
  # Usage:
  #
  # darken("80E619", 20) == "4D8A0F"
  #
  def darken(name_or_hex, percentage)
    hsl = Color::RGB.by_css(name_or_hex).to_hsl
    hsl.l -= normalize_percentage(percentage)
    hsl.to_rgb.hex.upcase
  end

  def css_to_rgb_array(css)
    color = Color::RGB.by_css(css)
    [color.red.to_i, color.green.to_i, color.blue.to_i]
  end

  def normalize_percentage(percentage)
    percentage.to_f / 100.to_f
  end

end

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

  def css_to_rgb_array(css)
    color = Color::RGB.by_css(css)
    [color.red.to_i, color.green.to_i, color.blue.to_i]
  end
end

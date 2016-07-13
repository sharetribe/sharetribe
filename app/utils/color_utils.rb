module ColorUtils

  module_function

  # Same as in filter: brightness(80%) in CSS
  #
  # The implementation operates on RBG space according
  # to CSS filter effects spec.
  #
  # Usage:
  #
  # brightness("80E619", 80) == "66B814"
  #
  def brightness(name_or_hex, percentage)
    p = normalize_percentage(percentage)
    rgb = Color::RGB.by_css(name_or_hex)

    Color::RGB.new(
      rgb.r * p,
      rgb.g * p,
      rgb.b * p,
      1
    ).hex.upcase
  end

  def css_to_rgb_array(css)
    color = Color::RGB.by_css(css)
    [color.red.to_i, color.green.to_i, color.blue.to_i]
  end

  def normalize_percentage(percentage)
    percentage.to_f / 100.to_f
  end

end

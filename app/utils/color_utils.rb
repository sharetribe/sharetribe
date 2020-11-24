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

  def darken(name_or_hex, amount)
    adjust(name_or_hex, -amount)
  end

  def lighten(name_or_hex, amount)
    adjust(name_or_hex, amount)
  end

  # Adjust the color by given amount of Lightness in HSL color space.
  # This is what SASS does internally with the darken and lighten function.
  def adjust(name_or_hex, amount)
    c = Color::RGB.by_css(name_or_hex).to_hsl
    c.lightness += amount
    c.to_rgb.hex
  end

  # Compute color transformations for given set of colors
  #
  # color_specs is array of hashes like:
  # { color: HEX, transforms: [ { fn: FUNCTION, levels: ARRAY }, ... ] }
  # Example:
  # [
  #   { color: "ff000",
  #     transforms: [
  #       { fn: :darken, levels: [0, 5, 10] }
  #     ]
  #   }
  # ]
  # Result is hash like:
  # { COLOR: { FN: { LEVEL: VALUE, ... }, ... } }
  # Example result:
  # {
  #   "ff0000" => {
  #     "darken" => {
  #       0  => "red",
  #       5  => "#e60000",
  #       10 => "#cc0000"
  #     }
  #   }
  # }
  # This is using Sass to compute the color values
  # This function is slow (due to SASS), but has the benefit of translating
  # certain color hex values to human-readable names (e.g. ff0000 - red).
  def sass_color_variations(color_specs)
    parse_regex = Regexp.new(/color_(\w+)_(\w+)_(\d+): (.*);/)
    color_map = {}

    # Parse color values out of compiled CSS string
    Sass.compile(_color_styles(color_specs))
      .lines
      .select { |l| l.match(/color_/) }
      .each { |l|
        _, color, fn, level, value = *parse_regex.match(l)
        color_map[color] ||= {}
        color_map[color][fn] ||= {}
        color_map[color][fn][level.to_i] = value
      }

    color_map
  end

  def _color_styles_fn(color, fn, levels)
    levels.map { |level|
      "a { color_#{color}_#{fn}_#{level}: #{fn}(##{color}, #{level}%); }"
    }
  end

  def _color_styles(color_specs)
    styles = []
    color_specs.each do |cs|
      cs[:transforms].each do |t|
        styles.append(_color_styles_fn(cs[:color], t[:fn], t[:levels]))
      end
    end
    styles.join("\n")
  end

end

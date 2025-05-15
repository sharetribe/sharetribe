require_relative 'section/base'
require_relative 'section/hero'
require_relative 'section/info'
require_relative 'section/footer'
require_relative 'section/listings'
require_relative 'section/categories'
require_relative 'section/locations'
require_relative 'section/video'
require_relative 'section/info_single_column'
require_relative 'section/info_multi_column'

module LandingPageVersions
  module Section
    INFO = 'info'.freeze
    HERO = 'hero'.freeze
    FOOTER = 'footer'.freeze
    LISTINGS = 'listings'.freeze
    CATEGORIES = 'categories'.freeze
    LOCATIONS = 'locations'.freeze
    VIDEO = 'video'.freeze

    VARIATION_SINGLE_COLUMN = 'single_column'.freeze
    VARIATION_MULTI_COLUMN = 'multi_column'.freeze

    BACKGROUND_VARIATION_DARK = 'dark'.freeze
    BACKGROUND_VARIATION_LIGHT = 'light'.freeze
    BACKGROUND_VARIATION_TRANSPARENT = 'transparent'.freeze

    BACKGROUND_STYLE_IMAGE = 'image'.freeze
    BACKGROUND_STYLE_COLOR = 'color'.freeze
    BACKGROUND_STYLE_NONE = 'none'.freeze

    BACKGROUND_RESIZE_OPTIONS = {resize_to_limit: [2000, 1328]}.freeze
    LOCATION_IMAGE_RESIZE_OPTIONS = {resize_to_limit: [1000, 667]}.freeze
    CATEGORY_IMAGE_RESIZE_OPTIONS = {resize_to_limit: [1000, 667]}.freeze
  end
end

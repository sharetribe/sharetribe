# Require files on startup
#
# Autoload path approach does not work for lib files without
# a class to load

files_to_load = [
  "#{Rails.root}/app/utils/pattern_matching"
]

files_to_load.each { |file| require file }

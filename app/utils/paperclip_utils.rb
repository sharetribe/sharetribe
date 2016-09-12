module PaperclipUtils
  module_function

  # Return string passed as extra command lime options to ImageMagick's convert command
  def limit_options
    params = ""
    params << " -limit memory #{APP_CONFIG.image_processing_memory_limit}" if APP_CONFIG.image_processing_memory_limit
    params << " -limit map #{APP_CONFIG.image_processing_map_limit}" if APP_CONFIG.image_processing_map_limit
    params
  end
end

module ScssHelper
  
  def additional_font_pack_imports
    if APP_CONFIG.icon_pack == "ss-pika"
      return "@import 'ss-social'; \n @import 'ss-pika';".html_safe  
    end
  end
  
end

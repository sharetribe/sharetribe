#
# This module contains helper methods for dealing with the two
# icon sets we use: ss-pika and font-awesome
#
module IconHelper

  ICON_PACK = APP_CONFIG.icon_pack || "font-awesome"

  def icon_tag(icon_name, additional_classes=[])
    icon_class_tag(icon_class(icon_name), additional_classes)
  end

  def icon_class(icon_name)
    icon = ICON_MAP[ICON_PACK][icon_name]
    if icon.nil?
      icon = (ICON_PACK == "font-awesome" ? "icon-circle-blank" : "ss-record")
    end
    return icon
  end

  def self.icon_specified?(icon_name)
    ICON_MAP[ICON_PACK][icon_name].present?
  end

  def pick_icons(icon_pack, icons)
    ICON_MAP[icon_pack].slice(*icons)
  end

  def icon_class_tag(icon_class, additional_classes = [])
    classes_string = [icon_class].concat(additional_classes).join(" ")
    "<i class=\"#{classes_string}\"></i>".html_safe
  end

  def icon_map_tag(icon_map, icon_name, additional_classes = [])
    icon_class_tag(icon_map[icon_name], additional_classes)
  end

end

module CommonStylesHelper

  module_function

  def marketplace_colors(community)
    {
      marketplace_color1: community&.custom_color1 ? "##{community.custom_color1}" : "#4a90e2",
      marketplace_color2: community&.custom_color2 ? "##{community.custom_color2}" : "#2ab865"
    }
  end
end

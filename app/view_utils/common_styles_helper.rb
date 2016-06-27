module CommonStylesHelper

  module_function

  def marketplace_colors(community)
    {
      marketplace_color1: community ? "##{community.custom_color1}" : "#a64c5d",
      marketplace_color2: community ? "##{community.custom_color2}" : "#00a26c"
    }
  end
end

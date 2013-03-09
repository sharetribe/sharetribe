module EmailTemplateHelper
  
  def body_font
    {
      :size => "4", 
      :color => "#3c3c3c", 
      :face => "Helvetica Neue, Arial, Helvetica, sans-serif", 
      :style => "font-size:14px;line-height:20px;"
    }
  end
  
  def body_link_style
    "color:#d96e21; text-decoration: none;" 
  end
  
end
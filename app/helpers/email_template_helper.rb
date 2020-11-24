module EmailTemplateHelper

  def body_font
    {
      :size => "4",
      :color => "#3c3c3c",
      :face => "Helvetica Neue, Arial, Helvetica, sans-serif",
      :style => "font-size:14px;line-height:20px;"
    }
  end

  def quote_font
    {
      :size => "4",
      :color => "grey",
      :face => "Helvetica Neue, Arial, Helvetica, sans-serif",
      :style => "font-size:14px;line-height:20px;font-style: italic;"
    }
  end

  def big_quotation_mark_font
    {
      :size => "20",
      :color => "grey",
      :face => "Arial, Helvetica, sans-serif",
      :style => "font-size:40px;line-height:10px;font-weight: bold;"
    }
  end

end

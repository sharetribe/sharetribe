module ApplicationHelper
  
  # Removes whitespaces from HAML expressions
  def one_line(&block)
    haml_concat capture_haml(&block).gsub("\n", '')
  end
  
end

module HomepageHelper
  def filters_in_use?
    params[:q].present? || 
    (params[:category].present? && params[:category] != "all") || 
    (params[:share_type].present? && params[:share_type] != "all")
  end
end

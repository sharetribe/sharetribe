Given(/^there is a current landing page in community/) do
  @current_landing_page = LandingPageVersion.where(community: @current_community).order('version DESC').first
end


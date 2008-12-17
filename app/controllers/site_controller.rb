class SiteController < ApplicationController
  def about
    @title = :about_title
  end

  def help
    @title = :help_title
  end
  
  def terms
    @title = :terms_title
  end

end

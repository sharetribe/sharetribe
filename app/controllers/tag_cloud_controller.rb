class TagCloudController < ApplicationController

  def index
    
    @tags = Tag.tags(:limit => 100, :order => "count DESC")

  end


end

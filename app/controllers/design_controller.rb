class DesignController < ApplicationController
  layout "design"
  skip_filter :single_community_only
end

#
# This is a terrible piece of code that should be removed as soon as possible.
# It's a workaround for Rails 3 bug which causes ActionController::Base.helpers.asset_path
# to ignore the existing configurations (namely, asset host)
#
# Read more here:
# http://stackoverflow.com/questions/27609498/how-to-get-path-to-s3-assets-from-rails-controller
#
class ActionController::Base
  def self.helpers
    @helper_proxy ||= begin
      proxy = ActionView::Base.new
      proxy.config = config.inheritable_copy
      proxy.extend(_helpers)
    end
  end
end

class Styleguide::PagesController < ApplicationController
  include ReactOnRails::Controller
  layout "styleguide"

  before_action :data

  rescue_from ReactOnRails::PrerenderError do |err|
    Rails.logger.error(err.message)
    Rails.logger.error(err.backtrace.join("\n"))
    redirect_to client_side_hello_world_path,
                flash: { error: "Error prerendering in react_on_rails. See server logs." }
  end

  private

  def initialize_shared_store
    redux_store("SharedReduxStore", props: @app_props_server_render)
  end

  def data
    # This is the props used by the React component.
    @app_props_server_render = {}

  end
end

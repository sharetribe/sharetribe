class PlansController < ApplicationController
  skip_before_filter :verify_authenticity_token, :fetch_logged_in_user, :fetch_community, :fetch_community_membership
  skip_filter :check_email_confirmation

  include PlanService::ExternalPlanServiceInjector

  def create
    res = JWTUtils.decode(params[:token], external_plan_service[:jwt_secret])

    res.on_success {
      render json: {}, status: 200
    }.on_error {
      render json: {error: :unauthorized}, status: 401
    }
  end
end

class PlansController < ApplicationController
  skip_before_filter :verify_authenticity_token, :fetch_logged_in_user, :fetch_community, :fetch_community_membership
  skip_filter :check_email_confirmation

  include PlanService::ExternalPlanServiceInjector

  def create
    res = JWTUtils.decode(params[:token], external_plan_service[:jwt_secret]).and_then {
      parse_json(request.raw_post)
    }.on_success { |ext_plans|
      Maybe(ext_plans)["plans"].or_else([]).map { |ext_plan|
        to_plan_entity(ext_plan)
      }.each { |plan|
        PlanService::API::Api.plans.create(community_id: plan[:community_id], plan: plan)
      }

      render json: {}, status: 200
    }.on_error { |error_msg, data|
      case data[:error_code]
      when :decode_error
        render json: {error: :unauthorized}, status: 401
      when :verification_error
        render json: {error: :unauthorized}, status: 401
      when JSON::ParserError
        render json: {error: :json_parser_error}, status: 400
      else
        render json: {error: :unknown_error}, status: 500
      end
    }
  end

  # private

  def parse_json(body)
    begin
      Result::Success.new(JSON.parse(body))
    rescue StandardError => e
      Result::Error.new(e)
    end
  end

  # Converts plan hash from external service to the format
  # that is expected by PlanService::API::Api.plans.create
  def to_plan_entity(plan)
    {
      community_id: plan["marketplace_id"],
      plan_level: plan["plan_level"],
      expires_at: Maybe(plan)["expires_at"].map { |ts| TimeUtils.utc_str_to_time(ts) }.or_else(nil)
    }
  end
end

class IntApi::MarketplacesController < ApplicationController

  skip_filter :single_community_only
  skip_filter :dashboard_only

  # Creates a marketplace and an admin user for that marketplace
  def create
    community = MarketplaceService::API::Marketplaces::create(params.slice(:marketplace_name, :marketplace_type, :marketplace_country, :marketplace_language))

    person_hash = {person: {
      given_name: params[:admin_first_name],
      family_name: params[:admin_last_name],
      email: params[:admin_email],
      password: params[:admin_password]
      },
      locale: params[:marketplace_language]
    }

    user = UserService::API::Users::create_user_and_make_a_member_of_community(person_hash, community)

    # create auth token for the new admin and return that with the link

    # Add user to mailchimp list

    response.status = 201
    render :json => ["Marketplace created."] and return
  end

end

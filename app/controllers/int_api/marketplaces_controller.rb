class IntApi::MarketplacesController < ApplicationController

  skip_filter :single_community_only
  skip_filter :dashboard_only

  # Creates a marketplace and an admin user for that marketplace
  def create


    MarketplaceService::API::Marketplaces::create(params.slice(:marketplace_name, :marketplace_type, :marketplace_country, :marketplace_language))
    #UserService::API::Users::create_user(params.slice(:admin_email, :admin_first_name, :admin_last_name, :admin_password))

    # MUST VALIDATE USER INPUT HERE AS IT COULD BE ANYTHING
    # actually for user enough to see if command passed
    # and for marketplace too

    # create auth token for the new admin and return that with the link

    # Add user to mailchimp list

    response.status = 201
    render :json => ["Marketplace created."] and return
  end

end

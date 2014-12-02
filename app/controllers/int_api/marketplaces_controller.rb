class IntApi::MarketplacesController < ApplicationController

  skip_filter :single_community_only
  skip_filter :dashboard_only
  skip_filter :fetch_community

  before_filter :set_access_control_headers

  class EmailAvailableValidator < ActiveModel::Validator
    def validate(form)
      options[:fields].each do |f|
        email_address = form.send(f)
        form.errors.add(f, "Email address #{email_address} is not available.") unless Email.email_available?(email_address)
      end
    end
  end


  NewMarketplaceForm = FormUtils.define_form("NewMarketplaceForm",
    :admin_email, :admin_first_name, :admin_last_name, :admin_password,
    :marketplace_country, :marketplace_language, :marketplace_name, :marketplace_type
  ).with_validations do
    validates_presence_of :admin_email, :admin_first_name, :admin_last_name, :admin_password, :marketplace_country, :marketplace_language, :marketplace_name, :marketplace_type
    validates_format_of   :admin_email, with: /\A[A-Z0-9._%\-\+\~\/]+@([A-Z0-9-]+\.)+[A-Z]+\z/i
    validates_with        EmailAvailableValidator, fields: [:admin_email]
    validates_length_of   :admin_password, minimum: 8
    validates             :marketplace_type, inclusion: { in: %w(product rental service) }
    validates_length_of   :marketplace_country, is: 2
    validates_length_of   :marketplace_language, minimum: 2
    validates_length_of   :admin_first_name, in: 1..255
    validates_length_of   :admin_last_name, in: 1..255
  end

  # Creates a marketplace and an admin user for that marketplace
  def create
    form = NewMarketplaceForm.new(params)
    return render status: 400, json: form.errors unless form.valid?

    # As there's no community yet, we store the global service name to thread
    # so that mail confirmation email is sent from global service name instead
    # of the just created marketplace's name
    ApplicationHelper.store_community_service_name_to_thread(APP_CONFIG.global_service_name)

    marketplace = MarketplaceService::API::Marketplaces.create(
      params.slice(:marketplace_name,
                   :marketplace_type,
                   :marketplace_country,
                   :marketplace_language).merge(paypal_enabled: true)
      )

    user = UserService::API::Users.create_user_with_membership({
        given_name: params[:admin_first_name],
        family_name: params[:admin_last_name],
        email: params[:admin_email],
        password: params[:admin_password],
        locale: params[:marketplace_language]},
      marketplace[:id])

    auth_token = UserService::API::AuthTokens.create_login_token(user[:id])
    url = URLUtils.append_query_param(marketplace[:url], "auth", auth_token[:token])

    # TODO Add user to mailchimp list

    # TODO handle error cases with proper response

    render status: 201, json: {"marketplace_url" => url}
  end

  # This could be more logical in different controller, but as implementing
  # at this point only tiny int-api with 2 methods, using one controller
  def check_email_availability
    email = params[:email]
    render :json => ["email parameter missing"], :status => 400 and return if email.blank?

    # When email availability has been asked, store that email to DB
    ProspectEmail.create(:email => params[:email])

    response.status = 200
    render :json => {:email => email, :available => (Email.email_available?(email))} and return
  end

  private

  def set_access_control_headers
    # TODO change this to more strict setting when done testing
    headers['Access-Control-Allow-Origin'] = '*'
  end

end

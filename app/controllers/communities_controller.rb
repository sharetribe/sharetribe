class CommunitiesController < ApplicationController
  skip_before_action :fetch_community,
              :perform_redirect,
              :cannot_access_if_banned,
              :cannot_access_without_confirmation,
              :ensure_consent_given,
              :ensure_user_belongs_to_community

  before_action :ensure_no_communities

  layout 'blank_layout'

  NewMarketplaceForm = Form::NewMarketplace

  def new
    render_form
  end

  def create
    form = NewMarketplaceForm.new(params)

    if form.valid?
      form_hash = form.to_hash
      marketplace = MarketplaceService.create(
        form_hash.slice(:marketplace_name,
                        :marketplace_type,
                        :marketplace_country,
                        :marketplace_language)
      )

      user = UserService::API::Users.create_user({
        given_name: form_hash[:admin_first_name],
        family_name: form_hash[:admin_last_name],
        email: form_hash[:admin_email],
        password: form_hash[:admin_password],
        locale: form_hash[:marketplace_language]},
        marketplace.id).data

      auth_token = UserService::API::AuthTokens.create_login_token(user[:id])
      @user_token = auth_token[:token]
      url = URLUtils.append_query_param(marketplace.full_domain({with_protocol: true}), "auth", @user_token)
      redirect_to url
    else
      render_form(errors: form.errors.full_messages)
    end
  end

  private

  def render_form(errors: nil)
    render action: :new, locals: {
             title: 'Create a new marketplace',
             form_action: communities_path,
             errors: errors
           }
  end

  def ensure_no_communities
    redirect_to landing_page_path if communities_exist?
  end

  def communities_exist?
    Rails.env.test? ? false : Community.count > 0
  end
end

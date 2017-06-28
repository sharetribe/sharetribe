# coding: utf-8
class TopbarApiController < ApplicationController

  skip_before_action :cannot_access_without_confirmation, :ensure_consent_given

  def props
    locale = params[:locale]
    landing_page = params[:landing_page] == "true"
    community, user, community_customization = context_objects()
                                               .values_at(:community, :user, :community_customization)

    p = topbar_props(community, user, community_customization, locale, landing_page)
    m_ctx = marketplace_context(community, user)
    result = { props: p, marketplaceContext: m_ctx }

    respond_to do |format|
      format.html { render plain: result.to_json.html_safe }
      format.json { render json: result.to_json }
    end
  end


  private

  def context_objects
    { community: @current_community,
      user: @current_user,
      community_customization: @community_customization }
  end

  def topbar_props(community, user, community_customization, locale, landing_page)
    if locale
      I18n.locale = locale
    end

    props = TopbarHelper.topbar_props(
      community: community,
      user: user,
      path_after_locale_change: "",
      search_placeholder: community_customization&.search_placeholder,
      locale_param: params[:locale],
      landing_page: landing_page,
      host_with_port: request.host_with_port)

    # Drop language links from the properties because the
    # path_after_locale_change is not available in this
    # controller. Assumption is that dynamic props fetched via this
    # endpoint are merged in over existing static properties that
    # already have working language change links. This is a quick fix
    # and a better way to do this would be to handle it entirely on
    # the JS side inside the component.
    props.delete(:locales)
    props.delete(:marketplace)
    props
  end

  def marketplace_context(community, user)
    # This is just the extensions part of the marketplaceContext
    # (railsContext) and is assumed to be merged over an existing full
    # context. We cannot build the full context because we don't know
    # the path from where this is being called from (nor should that
    # be the job of the server to handle).
    result = {
      # Extensions
      marketplaceId: community&.id,
      loggedInUsername: user&.username
    }.merge(CommonStylesHelper.marketplace_colors(community))

    result
  end
end

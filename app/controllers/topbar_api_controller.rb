# coding: utf-8
class TopbarApiController < ApplicationController

  def props
    locale = params[:locale]
    p = topbar_props(context_objects(), locale)
    respond_to do |format|
      format.html { render text: p.to_json.html_safe }
      format.json { render json: p.to_json }
    end
  end


  private

  def context_objects
    { community: @current_community,
      user: @current_user,
      community_customization: @community_customization }
  end

  def topbar_props(ctx, locale)
    if locale
      I18n.locale = locale
    end

    community, user, community_customization = ctx.values_at(:community, :user, :community_customization)

    props = TopbarHelper.topbar_props(
      community: community,
      user: user,
      path_after_locale_change: "",
      search_placeholder: community_customization&.search_placeholder,
      locale_param: params[:locale])

    # Drop language links from the properties because the
    # path_after_locale_change is not available in this
    # controller. Assumption is that dynamic props fetched via this
    # endpoint are merged in over existing static properties that
    # already have working language change links. This is a quick fix
    # and a better way to do this would be to handle it entirely on
    # the JS side inside the component.
    props.delete(:locales)
    props
  end
end

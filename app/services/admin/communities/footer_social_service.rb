class Admin::Communities::FooterSocialService
  attr_reader :community, :params

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def social_links
    return @social_links if defined?(@social_links)
    SocialLink.social_provider_list.each do |provider|
      next if community.social_links.by_provider(provider).any?
      community.social_links.build(provider: provider)
    end
    @social_links = community.social_links
  end

  def update
    community.update_attributes(social_links_params)
  end

  private

  def social_links_params
    params.require(:community).permit(
      social_links_attributes: [
        :id, :provider, :url, :sort_priority, :enabled
      ]
    )
  end
end

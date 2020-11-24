class AddServiceNameToCommunityCustomizations < ActiveRecord::Migration
  def up
    Community.find_each do |community|
      community.locales.each do |locale|
        unless community_customization = CommunityCustomization.find_by_community_id_and_locale(community.id, locale)
          community_customization = CommunityCustomization.new(:community_id => community.id, :locale => locale)
        end
        community_customization.name = community_name(community, community_customization)
        community_customization.save
      end
    end
  end

  def down
  end

  def community_name(community, community_customization)
    if community.settings && community.settings["service_name"].present?
      return community.settings["service_name"]
    elsif community_customization.name
      return community_customization.name
    elsif community.read_attribute(:name) 
      return community.read_attribute(:name)
    else
      return APP_CONFIG.global_service_name || "Sharetribe"
    end
  end

end

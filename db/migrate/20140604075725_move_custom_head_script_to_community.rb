class MoveCustomHeadScriptToCommunity < ActiveRecord::Migration
  def up
    ensure_each_community_has_at_most_one_custom_head_script
    
    add_column :communities, :custom_head_script, :text
    Community.reset_column_information
    
    communities_with_custom_head_scripts.each do |community, scripts| 
      community.update_column(:custom_head_script, scripts.first)
    end
    
    remove_column :community_customizations, :custom_head_script
  end

  def down
    add_column :community_customizations, :custom_head_script, :text
    CommunityCustomization.reset_column_information
    
    Community.where("custom_head_script IS NOT NULL").find_each do |community|
      community.locales.each do |locale|
        customization = community.community_customizations.where(locale: locale).first_or_initialize
        customization.custom_head_script = community[:custom_head_script]
        customization.save
      end
    end
    
    remove_column :communities, :custom_head_script
  end
  
  private
  
  def communities_with_custom_head_scripts
    CommunityCustomization
      .where("custom_head_script IS NOT NULL")
      .where("custom_head_script != ''")
      .includes(:community)
      .group_by(&:community)
      .map do |community, customizations| 
      [ community, customizations.map(&:custom_head_script) ]
    end
  end
  
  def ensure_each_community_has_at_most_one_custom_head_script
    communities_with_custom_head_scripts.each do |community, scripts|
      if differing_scripts = scripts.each_cons(2).any? { |a,b| a != b }
        print_differing_scripts_error_message(community, scripts)
        raise RuntimeError.new("Communities with differing custom head scripts detected.")          
      end
    end
  end
  
  def print_differing_scripts_error_message(community, differing_scripts)
    puts <<END

Different custom head scripts for different locales are no longer supported.

This community (id=#{community.id}) has two custom head scripts that differ:
END
    
    differing_scripts.each do |script|
      puts "\n\"#{script}\"\n"
    end
    
    puts <<END

Delete the script you don't want to keep. To accomplish different script 
behavior in different locales, detect the locale in JavaScript.

END
  end
end

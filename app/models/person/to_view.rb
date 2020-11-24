class Person
  module ToView
  extend ActiveSupport::Concern

  def name_or_username(community_or_display_type=nil)
    display_type = if community_or_display_type.present? && community_or_display_type.class == Community
      community_or_display_type.name_display_type
    else
      community_or_display_type
                   end
    if given_name.present?
      if display_type
        case display_type
        when "first_name_with_initial"
          return first_name_with_initial
        when "first_name_only"
          return given_name
        else
          return full_name
        end
      else
        return first_name_with_initial
      end
    else
      return username
    end
  end

  def full_name
    "#{given_name} #{family_name}"
  end

  def first_name_with_initial
    initial = if family_name
      family_name[0,1]
    else
      ""
              end
    "#{given_name} #{initial}"
  end

  def name(community_or_display_type)
    return name_or_username(community_or_display_type)
  end

  def given_name_or_username
    if given_name.present?
      return given_name
    else
      return username
    end
  end
  end
end

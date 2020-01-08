module LandingPageVersion::DataStructure
  extend ActiveSupport::Concern

  def sections
    return @sections if defined?(@sections)

    sections = []
    parsed_content['sections'].each do |content_section|
      case content_section['kind']
      when LandingPageVersion::Section::HERO
        sections << LandingPageVersion::Section::Hero.new_from_content(content_section.merge(
            'landing_page_version' => self,
            'previous_id' => content_section['id']
          ))
      when LandingPageVersion::Section::FOOTER
        sections << LandingPageVersion::Section::Footer.new_from_content(content_section.merge(
            'landing_page_version' => self,
            'previous_id' => content_section['id']
          ))
      when LandingPageVersion::Section::INFO
        sections << LandingPageVersion::Section::Info.new_from_content(content_section.merge(
            'landing_page_version' => self,
            'previous_id' => content_section['id']
          ))
      when LandingPageVersion::Section::LISTINGS
        sections << LandingPageVersion::Section::Listings.new_from_content(content_section.merge(
            'landing_page_version' => self,
            'previous_id' => content_section['id']
          ))
      when LandingPageVersion::Section::CATEGORIES
        sections << LandingPageVersion::Section::Categories.new_from_content(content_section.merge(
            'landing_page_version' => self,
            'previous_id' => content_section['id']
          ))
      when LandingPageVersion::Section::LOCATIONS
        sections << LandingPageVersion::Section::Locations.new_from_content(content_section.merge(
            'landing_page_version' => self,
            'previous_id' => content_section['id']
          ))
      when LandingPageVersion::Section::VIDEO
        sections << LandingPageVersion::Section::Video.new_from_content(content_section.merge(
            'landing_page_version' => self,
            'previous_id' => content_section['id']
          ))
      end
    end
    @sections = sections
  end

  def section_positions
    return @section_positions if defined?(@section_positions)

    existing_sections = parsed_content['sections'].dup
    composition = parsed_content['composition'].dup
    section_positions = []
    composition.each_with_index do |item, index|
      section_id = item['section']['id']
      existing_section = existing_sections.find{|x| x['id'] == section_id}
      next unless existing_section

      attrs = existing_section.slice('id', 'kind', 'variation')
      attrs['position'] = index
      section_positions << LandingPageVersion::SectionPosition.new(attrs)
    end
    @section_positions = section_positions
  end

  def section_positions_attributes=(section_positions_params)
    composition = []
    section_positions_params.values.sort_by { |a| a['position'].to_i }.each do |section_position|
      composition << { 'section' => {'type' => 'sections', 'id' =>  section_position['id'] }}
    end
    new_content = parsed_content.dup
    new_content['composition'] = composition
    update_content(new_content)
  end

  def parsed_content
    @parsed_content ||= JSON.parse(content)
  end

  def update_content(new_content)
    @parsed_content = nil

    # ensure hero is first and footer is last
    composition = new_content['composition']
    hero = composition.find{|x| x['section']['id'] == 'hero' }
    footer = composition.find{|x| x['section']['id'] == 'footer' }
    inner_content = composition.select{|x| x != hero && x != footer }
    new_content['composition'] = ([hero] + inner_content + [footer]).compact

    update(content: new_content.to_json)
  end
end

module LandingPageVersion::DataStructure
  extend ActiveSupport::Concern

  def section_positions
    return @section_positions if defined?(@section_positions)
    existing_sections = parsed_content['sections'].dup
    composition = parsed_content['composition'].dup
    section_positions = []
    composition.each_with_index do |item, index|
      section_id = item['section']['id']
      existing_section = existing_sections.find{|x| x['id'] == section_id}
      if existing_section
        attrs = existing_section.slice('id', 'kind')
        attrs['position'] = index
        section_positions << LandingPageVersion::SectionPosition.new(attrs)
      end
    end
    @section_positions = section_positions
  end

  def section_positions_attributes=(section_positions_params)
    composition = []
    section_positions_params.values.sort{|a, b| a['position'] <=> b['position']}.each do |section_position|
      composition << { 'section' => {'type' => 'sections', 'id' =>  section_position['id'] }}
    end
    new_content = parsed_content.dup
    new_content['composition'] = composition
    @parsed_content = nil
    update(content: new_content.to_json)
  end

  def parsed_content
    @parsed_content ||= JSON.parse(content)
  end
end

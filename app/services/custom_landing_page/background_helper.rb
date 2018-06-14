module CustomLandingPage
  module BackgroundHelper
    def background_style_modifiers(s, second_wo_background)
      background_image_modifiers = {
        'light' => 'background-image--light',
        'dark' => 'background-image--dark',
        'transparent' => 'background'
      }
      background_image_modifiers.default = 'background-image--dark'

      background_image_enabled  = !s['background_image'].nil?
      background_image_style    = background_image_enabled ? "background-image: url('#{s['background_image']['src']}');" : ''
      background_color_enabled  = !s['background_color'].nil?
      background_color_style    = background_color_enabled ? "background-color: rgb(#{s['background_color'].join(',')});" : ''

      section_style_modifier =
        if background_image_enabled
          background_image_modifiers[s['background_image_variation']]
        elsif background_color_enabled
          'background-color'
        elsif second_wo_background
          'zebra'
        else
          'blank'
        end

      button_modifier =
        if background_image_enabled
          ''
        elsif background_color_enabled
          '--inverted'
        else
          '--ghost'
        end

      variation_modifiers = {
        'single_column' => 'single-column',
        'multi_column'  => 'multi-column',
      }
      variation_modifier        = variation_modifiers[s['variation']]

      {
        background_image_style: background_image_style,
        background_color_style: background_color_style,
        section_style_modifier: section_style_modifier,
        button_modifier: button_modifier,
        variation_modifier: variation_modifier
      }
    end

    def calculate_second_wo_background(section)
      @landing_page_zebra_row ||= false
      @landing_page_second_wo_background ||= false
      if %w(info listings categories locations).include?(section["kind"]) && section["background_image"].nil? && section["background_color"].nil?
        if @landing_page_zebra_row
          @landing_page_second_wo_background = !@landing_page_second_wo_background
        else
          @landing_page_zebra_row = true
        end
      else
        @landing_page_zebra_row = false
        @landing_page_second_wo_background = false
      end
      @landing_page_second_wo_background
    end
  end
end

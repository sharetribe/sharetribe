class LandingPageVersion::SectionPosition
  include ActiveModel::Model

  attr_accessor(
    :id,
    :position,
    :kind,
    :variation,
    :columns
  )

  def removable?
    kind != LandingPageVersion::Section::HERO && kind != LandingPageVersion::Section::FOOTER
  end

  def kind_info
    if kind == LandingPageVersion::Section::INFO
      if variation == 'single_column'
        I18n.t('admin2.landing_page.sections.type.column_1')
      else
        I18n.t("admin2.landing_page.sections.type.column_#{columns}")
      end
    else
      I18n.t("admin2.landing_page.sections.type.#{kind}")
    end
  end

  def sortable?
    removable? ? true: nil
  end
end

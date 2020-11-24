class LandingPageVersion::SectionPosition
  include ActiveModel::Model

  attr_accessor(
    :id,
    :position,
    :kind,
    :variation
  )

  def removable?
    kind != LandingPageVersion::Section::HERO && kind != LandingPageVersion::Section::FOOTER
  end

  def sortable?
    removable? ? true: nil
  end
end

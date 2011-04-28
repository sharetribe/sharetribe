class ShareType < ActiveRecord::Base

  belongs_to :listing

  # Clean out unnecessary details from the JSON literal
  def as_json(options = {})
    self.name
  end

end

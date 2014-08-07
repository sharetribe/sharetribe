class Booking < ActiveRecord::Base

  belongs_to :conversation

  attr_accessible :conversation_id, :end_on, :start_on

  validates_date :start_on, on_or_after: :today
  validates_date :end_on, on_or_after: :start_on

  def duration
    (end_on - start_on).to_i + 1
  end

  def self.new_from_params(params)
    start_on = Date.strptime(params[:start_on], I18n.t('date.export_date_formats.ruby_style_date'))
    end_on = Date.strptime(params[:end_on], I18n.t('date.export_date_formats.ruby_style_date'))

    Booking.new(:start_on => start_on, :end_on => end_on)
  end


end

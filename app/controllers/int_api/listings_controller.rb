class IntApi::ListingsController < ApplicationController
  respond_to :json

  def update_working_time_slots
    listing.update_attributes(working_time_slots_params)
    respond_with listing.working_hours_as_json, location: nil
  end

  private

  def listing
    @listing ||= Listing.find(params[:id])
  end

  def working_time_slots_params
    params.require(:listing).permit(
      working_time_slots_attributes: [ :id, :from, :till, :week_day, :_destroy ]
    )
  end
end

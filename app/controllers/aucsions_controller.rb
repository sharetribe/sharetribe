class AucsionsController < ApplicationController
  def update
    aucsion.person_id = current_user.id
    aucsion.update(aucsion_params)
  end

  private

  def aucsion
    @aucsion ||= Aucsion.find(params[:id])
  end
  helper_method :aucsion

  def aucsion_params
    params.require(:aucsion).permit(:person_id, :price_aucsion, :category_id, :listing_shape_id)
  end
end

class Mercury::ImagesController < MercuryController

  # POST /images.json
  def create
    image = Mercury::Image.new(params.require(:image).permit(:image))
    image.save

    respond_to do |format|
      format.json { render json: image }
    end
  end
end

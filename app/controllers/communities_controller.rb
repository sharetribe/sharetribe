class CommunitiesController < ApplicationController
  skip_filter :fetch_community,
              :cannot_access_without_joining

  layout 'blank_layout'

  NewMarketplaceForm = Form::NewMarketplace

  def new
    render_form
  end

  def create
    form = NewMarketplaceForm.new(params)

    if form.valid?
      marketplace = MarketplaceService::API::Marketplaces.create(form.to_hash)
      redirect_to marketplace[:url]
    else
      render_form(error_msg: form.errors.full_messages.join(", "))
    end
  end

  private

  def render_form(error_msg: nil)
    render action: :new, locals: {
             title: 'Create a new marketplace',
             form_action: communities_path,
             errors: error_msg
           }
  end
end

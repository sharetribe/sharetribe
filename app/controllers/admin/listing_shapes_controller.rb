class Admin::ListingShapesController < ApplicationController
  before_filter :ensure_is_admin

  # TODO before_filter :feature_flag

  def index
    render("index",
           locals: {
             selected_left_navi_link: "listing_shapes",
             listing_shapes: [{id: 1, name: "Selling products", categories: "Foo, Bar, Doo"},
                              {id: 2, name: "Renting spaces", categories: "Quux, Wau, Ohno"}]})
  end
end

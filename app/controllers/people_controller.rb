class PeopleController < ApplicationController
  
  def show
    @person = Person.find(params[:id])
  end

  def new
  end

  def create
  end

  def edit
  end

end

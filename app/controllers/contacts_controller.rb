class ContactsController < ApplicationController
  def index
    save_navi_state(['own', 'contacts'])
    @title = :contacts
  end

  def add
  end

end

class ContactsController < ApplicationController
  def index
    save_navi_state(['people', 'contacts'])
    @title = :contacts
  end

  def add
  end

end

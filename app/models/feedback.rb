class Feedback < ActiveRecord::Base

  belongs_to :author, :class_name => "Person"

  validates_presence_of :content, :author_id, :url

  attr_accessor :title

  # Format author name & email correctly
  def author_name_and_email
    if author
      "#{author.name} (#{author.email})"
    elsif !email.blank?
      "Unlogged user (#{email})"
    else
      "Anonymous user"
    end
  end

end

class Comment < ActiveRecord::Base
  
  belongs_to :author, :class_name => "Person"
  belongs_to :listing
  
  validates_length_of :content, :minimum => 1, :maximum => 5000, :allow_nil => false
  
  def send_email_to_listing_author(host)
    if !listing.author.id.eql?(author.id) && listing.author.should_receive?("email_about_new_comments_to_own_listing")
      PersonMailer.new_comment_to_own_listing_notification(self, host).deliver
    end  
  end
  
end

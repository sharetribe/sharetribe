class MailWorker < Workling::Base

  include VisibilityHelper

  def send_mail_to_friends_about_listing(options)
    listing = Listing.find(options[:listing_id])
    cookie = options[:cookie]
    # Send mail to a friend only if he/she is allowed to see the listing and has
    # allowed mail notifications of new listings from friends.
    listing.author.friends(cookie).each do |friend|
      count = Listing.count(:all, :conditions => ["id = ?" + get_visibility_conditions("listing", friend, cookie), options[:listing_id]])
      if friend.settings.email_when_new_listing_from_friend == 1 && count == 1
        listing.update_attribute(:title, listing.title + " " + friend.name)
        UserMailer.deliver_notification_of_new_listing_from_friend(listing, friend, options[:protocol], options[:host])
      end  
    end
  end

end
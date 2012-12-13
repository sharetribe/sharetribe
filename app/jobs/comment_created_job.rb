class CommentCreatedJob < Struct.new(:comment_id, :community_id, :host) 
  
  # This before hook should be included in all Jobs to make sure that the service_name is 
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_host(host)
  end
  
  def perform
    comment = Comment.find(comment_id)
    comment.send_notifications(host)
    Badge.assign_with_levels("commentator", comment.author.authored_comments.count, comment.author, [3, 10, 30], host)
    EventFeedEvent.create(:person1_id => comment.author.id, :eventable_id => comment_id, :eventable_type => "Comment", :community_id => community_id, :category => "comment", :members_only => !comment.listing.public?)
  end

end
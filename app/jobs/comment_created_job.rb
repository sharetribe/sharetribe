class CommentCreatedJob < Struct.new(:comment_id, :community_id, :host) 

  def perform
    comment = Comment.find(comment_id)
    comment.send_notifications(host)
    Badge.assign_with_levels("commentator", comment.author.authored_comments.count, comment.author, [3, 10, 30], host)
    EventFeedEvent.create(:person1_id => comment.author.id, :eventable_id => comment_id, :eventable_type => "Comment", :community_id => community_id, :category => "comment", :members_only => !comment.listing.visibility.eql?("everybody"))
  end

end
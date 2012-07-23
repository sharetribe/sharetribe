class Statistic < ActiveRecord::Base
  belongs_to :community
  
  def initialize(params = {})
    super(params)

    throw "Doesn't yet support counting statistics for a community" if self.community

    # Users count
    self.users_count = Person.count

    #activation
    # create content in first 2 weeks (average of recent month)
    six_to_two_week_old_users = Person.where(:created_at => (6.weeks.ago..2.weeks.ago))
    activated = 0
    six_to_two_week_old_users.each do |u|
      creation_date = u.created_at
      if Listing.where(:author_id => u.id, :created_at => (creation_date..(creation_date + 2.weeks))).present? || Comment.where(:author_id => u.id, :created_at => (creation_date..(creation_date + 2.weeks))).present? || Message.where(:sender_id => u.id, :created_at => (creation_date..(creation_date + 2.weeks))).present? 
        activated += 1
      end      
    end
    @active_in_first_two_weeks = activated
    @total_users_for_first_two_weeks = six_to_two_week_old_users.count
    self.two_week_content_activation_percentage = (@active_in_first_two_weeks*1.0 / @total_users_for_first_two_weeks).round(4)

    # participate in transcation in first month (average of recent month)
    one_to_two_month_old_users = Person.where(:created_at => (2.months.ago..1.month.ago))
    activated = 0
    one_to_two_month_old_users.each do |u|
      creation_date = u.created_at
      if u.conversations.where(:status => "accepted", :created_at => (creation_date..(creation_date + 1.month))).present?
        activated += 1
      end      
    end
    @transaction_in_first_month = activated
    @total_users_for_first_month = one_to_two_month_old_users.count
    self.four_week_transaction_activation_percentage = (@transaction_in_first_month*1.0 / @total_users_for_first_month).round(4)


    #retention

    #CommunityMembership.where("last_page_load_date > ?", 1.months.ago).select("distinct(person_id)").uniq  #uniq not working as hoped here, so use SQL
    # G1 means users who did at least one page load as logged in
    @mau_g1 = CommunityMembership.find_by_sql("select distinct person_id from community_memberships where last_page_load_date > '#{1.month.ago.to_formatted_s(:db)}'").count
    @wau_g1 = CommunityMembership.find_by_sql("select distinct person_id from community_memberships where last_page_load_date > '#{7.days.ago.to_formatted_s(:db)}'").count
    @dau_g1 = CommunityMembership.find_by_sql("select distinct person_id from community_memberships where last_page_load_date > '#{24.hours.ago.to_formatted_s(:db)}'").count

    self.mau_g1 = ((@mau_g1*1.0/users_count)).round(4)
    self.wau_g1 = ((@wau_g1*1.0/users_count)).round(4)
    self.dau_g1 = ((@dau_g1*1.0/users_count)).round(4)
    
    # G2 means users did some content interaction: listing/comment/message or participated in transaction
    
    #Person.find_by_sql("select distinct author_id as person_id from comments where `updated_at` > '#{1.month.ago.to_formatted_s(:db)}'")
    
    c = Comment.where("created_at > '#{1.month.ago.to_formatted_s(:db)}'")
    l = Listing.where("created_at > '#{1.month.ago.to_formatted_s(:db)}'")
    m = Message.where("created_at > '#{1.month.ago.to_formatted_s(:db)}'")
    t = Conversation.where("updated_at > '#{1.month.ago.to_formatted_s(:db)}' AND status = 'accepted'")
    @mau_g2 = [c.collect(&:author_id), l.collect(&:author_id), m.collect(&:sender_id), t.collect(&:participants).flatten.collect(&:id)].flatten.uniq.count
    
    c = Comment.where("created_at > '#{7.days.ago.to_formatted_s(:db)}'")
    l = Listing.where("created_at > '#{7.days.ago.to_formatted_s(:db)}'")
    m = Message.where("created_at > '#{7.days.ago.to_formatted_s(:db)}'")
    t = Conversation.where("updated_at > '#{7.days.ago.to_formatted_s(:db)}' AND status = 'accepted'")
    @wau_g2 = [c.collect(&:author_id), l.collect(&:author_id), m.collect(&:sender_id), t.collect(&:participants).flatten.collect(&:id)].flatten.uniq.count
    
    c = Comment.where("created_at > '#{24.hours.ago.to_formatted_s(:db)}'")
    l = Listing.where("created_at > '#{24.hours.ago.to_formatted_s(:db)}'")
    m = Message.where("created_at > '#{24.hours.ago.to_formatted_s(:db)}'")
    t = Conversation.where("updated_at > '#{24.hours.ago.to_formatted_s(:db)}' AND status = 'accepted'")
    @dau_g2 = [c.collect(&:author_id), l.collect(&:author_id), m.collect(&:sender_id), t.collect(&:participants).flatten.collect(&:id)].flatten.uniq.count
   
    self.mau_g2 = ((@mau_g2*1.0/users_count)).round(4)
    self.wau_g2 = ((@wau_g2*1.0/users_count)).round(4)
    self.dau_g2 = ((@dau_g2*1.0/users_count)).round(4)
    
    # G3 means users who participated in a transaction
    @mau_g3 = Conversation.find_by_sql("select distinct person_id from conversations INNER JOIN `participations` ON `conversations`.`id`=`participations`.`conversation_id` where `conversations`.`status` = 'accepted' AND `conversations`.`updated_at` > '#{1.month.ago.to_formatted_s(:db)}'").count
    @wau_g3 = Conversation.find_by_sql("select distinct person_id from conversations INNER JOIN `participations` ON `conversations`.`id`=`participations`.`conversation_id` where `conversations`.`status` = 'accepted' AND `conversations`.`updated_at` > '#{7.days.ago.to_formatted_s(:db)}'").count
    @dau_g3 = Conversation.find_by_sql("select distinct person_id from conversations INNER JOIN `participations` ON `conversations`.`id`=`participations`.`conversation_id` where `conversations`.`status` = 'accepted' AND `conversations`.`updated_at` > '#{24.hours.ago.to_formatted_s(:db)}'").count   

    self.mau_g3 = ((@mau_g3*1.0/users_count)).round(4)
    self.wau_g3 = ((@wau_g3*1.0/users_count)).round(4)
    self.dau_g3 = ((@dau_g3*1.0/users_count)).round(4)

    #referral
    @inv_sent = Invitation.where("inviter_id is not NULL").count
    @inv_accepted = Invitation.where("inviter_id is not NULL and usages_left = 0").count
    self.invitations_accepted_per_user = @inv_accepted*1.0 / users_count
    self.invitations_sent_per_user = @inv_sent*1.0 / users_count


    #revenue
    @revenue_sum = 0
    Community.select(:monthly_price_in_euros).each do |d|
      @revenue_sum += d.monthly_price_in_euros if d.monthly_price_in_euros
    end
    self.revenue_per_mau_g1 = (@revenue_sum/@mau_g1).round(2)
    
    self.extra_data = { :active_in_first_two_weeks => @active_in_first_two_weeks, 
                        :total_users_for_first_two_weeks => @total_users_for_first_two_weeks, 
                        :transaction_in_first_month => @transaction_in_first_month,
                        :total_users_for_first_month => @total_users_for_first_month,
                        :mau_g1 => @mau_g1,
                        :wau_g1 => @wau_g1,
                        :dau_g1 => @dau_g1,
                        :mau_g2 => @mau_g2,
                        :wau_g2 => @wau_g2,
                        :dau_g2 => @dau_g2,
                        :mau_g3 => @mau_g3,
                        :wau_g3 => @wau_g3,
                        :dau_g3 => @dau_g3, 
                        :inv_sent => @inv_sent,
                        :inv_accepted => @inv_accepted,
                        :revenue_sum => @revenue_sum
                        }.to_json

    
  end
end

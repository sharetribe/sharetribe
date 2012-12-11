class Statistic < ActiveRecord::Base
  belongs_to :community
  
  def initialize(params = {}, options = {})
    super(params, options)

    #throw "Doesn't yet support counting statistics for a community" if community

    # Users count
    if community
      self.users_count = community.members.count
      self.users_count = 1 if self.users_count == 0 # 0 breaks the calculation, so expect that there should be at least 1 member.
      self.new_users_last_week = community.new_members_during_last(7.days).count
      self.new_users_last_month = community.new_members_during_last(30.days).count
    else
      self.users_count = Person.count
      self.new_users_last_week = Person.where(:created_at => (1.week.ago..Time.now)).count
      self.new_users_last_month = Person.where(:created_at => (1.month.ago..Time.now)).count
    end

    

    # Listings, Messages and Transactions count
    if community
      conversations = []
      community.members.each{ |m| conversations << m.conversations }
      
      #select only conversations that are duplicate (i.e. happening between members of this community)
      conversations.flatten!
      conversations = conversations.select{|c| conversations.count(c) == 2}.uniq        
      
      listings = community.listings
      messages = []
      conversations.each {|c| messages << c.messages}
      messages.flatten!
      transactions = conversations.select{|c| c.status == "accepted"}
    else
      conversations = Conversation.all
      listings = Listing.all
      messages = Message.all
      transactions = Conversation.where(:status => "accepted")
    end
    
    self.conversations_count = conversations.count
    self.new_conversations_last_week = conversations.select{|x| x.created_at > 1.week.ago}.count
    self.new_conversations_last_month = conversations.select{|x| x.created_at > 1.month.ago}.count
    self.listings_count = listings.count
    self.new_listings_last_week = listings.select{|x| x.created_at > 1.week.ago}.count
    self.new_listings_last_month = listings.select{|x| x.created_at > 1.month.ago}.count
    self.messages_count = messages.count
    self.new_messages_last_week = messages.select{|x| x.created_at > 1.week.ago}.count
    self.new_messages_last_month = messages.select{|x| x.created_at > 1.month.ago}.count
    self.transactions_count = transactions.count
    self.new_transactions_last_week = transactions.select{|x| x.created_at > 1.week.ago}.count
    self.new_transactions_last_month = transactions.select{|x| x.created_at > 1.month.ago}.count
    
    
 
    

    #activation
    # create content in first 2 weeks (average of recent month)
    six_to_two_week_old_users = community ? 
      CommunityMembership.where(:created_at => (6.weeks.ago..2.weeks.ago), :community_id => community.id) :
      Person.where(:created_at => (6.weeks.ago..2.weeks.ago))
    
    # NOTE: When calculating community stats six_to_two_week_old_users contains membership objects instead of people.
    
    activated = 0
    six_to_two_week_old_users.each do |u|
      creation_date = u.created_at
      u = u.person if u.class == CommunityMembership # Set u to point to the actual user if it now points to the membership object
      if u.present? && u.class == Person && (Message.where(:sender_id => u.id, :created_at => (creation_date..(creation_date + 2.weeks))).present? || Listing.where(:author_id => u.id, :created_at => (creation_date..(creation_date + 2.weeks))).present? || Comment.where(:author_id => u.id, :created_at => (creation_date..(creation_date + 2.weeks))).present?) 
        activated += 1
      end      
    end
    @active_in_first_two_weeks = activated
    @total_users_for_first_two_weeks = six_to_two_week_old_users.count
    self.two_week_content_activation_percentage = @total_users_for_first_two_weeks > 0 ? (@active_in_first_two_weeks*1.0 / @total_users_for_first_two_weeks).round(4) : 0

    # participate in transcation in first month (average of recent month)
    one_to_two_month_old_users = community ?
      CommunityMembership.where(:created_at => (2.months.ago..1.month.ago), :community_id => community.id) :
      Person.where(:created_at => (2.months.ago..1.month.ago))
      
    # NOTE: When calculating community stats one_to_two_month_old_users contains membership objects instead of people.
    
    activated = 0
    one_to_two_month_old_users.each do |u|
      creation_date = u.created_at
      u = u.person if u.class == CommunityMembership # Set u to point to the actual user if it now points to the membership object
      if  u.present? && u.class == Person && u.conversations.where(:status => "accepted", :created_at => (creation_date..(creation_date + 1.month))).present?
        activated += 1
      end      
    end
    @transaction_in_first_month = activated
    @total_users_for_first_month = one_to_two_month_old_users.count
    self.four_week_transaction_activation_percentage = @total_users_for_first_month > 0 ? (@transaction_in_first_month*1.0 / @total_users_for_first_month).round(4) : 0


    #retention

    #CommunityMembership.where("last_page_load_date > ?", 1.months.ago).select("distinct(person_id)").uniq  #uniq not working as hoped here, so use SQL
    # G1 means users who did at least one page load as logged in
    @mau_g1 = CommunityMembership.find_by_sql("select distinct person_id from community_memberships where last_page_load_date > '#{1.month.ago.to_formatted_s(:db)}' #{community ? "AND community_id = '#{community.id}'" : ""}").count
    @wau_g1 = CommunityMembership.find_by_sql("select distinct person_id from community_memberships where last_page_load_date > '#{7.days.ago.to_formatted_s(:db)}' #{community ? "AND community_id = '#{community.id}'" : ""}").count
    @dau_g1 = CommunityMembership.find_by_sql("select distinct person_id from community_memberships where last_page_load_date > '#{24.hours.ago.to_formatted_s(:db)}' #{community ? "AND community_id = '#{community.id}'" : ""}").count

    self.mau_g1_count = @mau_g1
    self.wau_g1_count = @wau_g1
    self.mau_g1 = ((@mau_g1*1.0/users_count)).round(4)
    self.wau_g1 = ((@wau_g1*1.0/users_count)).round(4)
    self.dau_g1 = ((@dau_g1*1.0/users_count)).round(4)
    
    # G2 means users did some content interaction: listing/comment/message or participated in transaction
    
    #Person.find_by_sql("select distinct author_id as person_id from comments where `updated_at` > '#{1.month.ago.to_formatted_s(:db)}'")
    
    @mau_g2 = count_active_users_g2(1.month.ago, community)
    @wau_g2 = count_active_users_g2(7.days.ago, community)
    @dau_g2 = count_active_users_g2(24.hours.ago, community)
   
    self.mau_g2 = ((@mau_g2*1.0/users_count)).round(4)
    self.wau_g2 = ((@wau_g2*1.0/users_count)).round(4)
    self.dau_g2 = ((@dau_g2*1.0/users_count)).round(4)
    
    # G3 means users who participated in a transaction
    mau_g3_ids = Conversation.find_by_sql("select distinct person_id from conversations INNER JOIN `participations` ON `conversations`.`id`=`participations`.`conversation_id` where `conversations`.`status` = 'accepted' AND `conversations`.`updated_at` > '#{1.month.ago.to_formatted_s(:db)}'")
    wau_g3_ids = Conversation.find_by_sql("select distinct person_id from conversations INNER JOIN `participations` ON `conversations`.`id`=`participations`.`conversation_id` where `conversations`.`status` = 'accepted' AND `conversations`.`updated_at` > '#{7.days.ago.to_formatted_s(:db)}'")
    dau_g3_ids = Conversation.find_by_sql("select distinct person_id from conversations INNER JOIN `participations` ON `conversations`.`id`=`participations`.`conversation_id` where `conversations`.`status` = 'accepted' AND `conversations`.`updated_at` > '#{24.hours.ago.to_formatted_s(:db)}'")
    
    if community #select only people that are members of the community
      mau_g3_ids = mau_g3_ids.select{|i| CommunityMembership.find_by_person_id_and_community_id(i.person_id, community.id)}
      wau_g3_ids = wau_g3_ids.select{|i| CommunityMembership.find_by_person_id_and_community_id(i.person_id, community.id)}
      dau_g3_ids = dau_g3_ids.select{|i| CommunityMembership.find_by_person_id_and_community_id(i.person_id, community.id)}
    end
    
    @mau_g3 = mau_g3_ids.count  
    @wau_g3 = wau_g3_ids.count
    @dau_g3 = dau_g3_ids.count  
    
    self.mau_g3 = ((@mau_g3*1.0/users_count)).round(4)
    self.wau_g3 = ((@wau_g3*1.0/users_count)).round(4)
    self.dau_g3 = ((@dau_g3*1.0/users_count)).round(4)



    # Growth
    
    # find a statistic 7 days ago
    last_weeks_stats = Statistic.where(:community_id => (community ? community.id : nil), :created_at => 7.4.days.ago..6.6.days.ago).first
    
    if last_weeks_stats
      self.user_count_weekly_growth = (self.users_count - last_weeks_stats.users_count)*1.0 /  last_weeks_stats.users_count
      self.wau_weekly_growth = (self.wau_g1_count - last_weeks_stats.wau_g1_count)*1.0 / (last_weeks_stats.wau_g1_count > 0 ? last_weeks_stats.wau_g1_count : 1)
    end


    #referral
    @inv_sent = Invitation.where("inviter_id is not NULL #{community ? "AND community_id = '#{community.id}'" : ""}").count
    @inv_accepted = Invitation.where("inviter_id is not NULL and usages_left = 0 #{community ? "AND community_id = '#{community.id}'" : ""}").count
    self.invitations_accepted_per_user = @inv_accepted*1.0 / users_count
    self.invitations_sent_per_user = @inv_sent*1.0 / users_count


    #revenue
    @revenue_sum = 0
    if community
      @revenue_sum = community.monthly_price_in_euros || 0
    else
      Community.select(:monthly_price_in_euros).each do |d|
        @revenue_sum += d.monthly_price_in_euros if d.monthly_price_in_euros
      end
    end
    self.revenue_per_mau_g1 = @mau_g1 > 0 ? (@revenue_sum/@mau_g1*100).round/100 : 0
    
    self.extra_data = { :active_in_first_two_weeks => @active_in_first_two_weeks, 
                        :total_users_for_first_two_weeks => @total_users_for_first_two_weeks, 
                        :transaction_in_first_month => @transaction_in_first_month,
                        :total_users_for_first_month => @total_users_for_first_month,
                        #:mau_g1 => @mau_g1,
                        #:wau_g1 => @wau_g1,
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
  
  def count_active_users_g2(time_frame, community=nil)
    if community
      # This might include activity of people acting in other communities, but not a too big problem for the accuracy
      l = community.listings.where("created_at > '#{time_frame.to_formatted_s(:db)}'")
      c = community.members.collect(&:authored_comments).flatten.select{|c| c.created_at > time_frame}
      m = community.members.collect(&:messages).flatten.select{|m| m.created_at > time_frame}
      t = community.members.collect(&:conversations).flatten.select{|t| t.status == "accepted" && t.updated_at > time_frame}
    else
      c = Comment.where("created_at > '#{time_frame.to_formatted_s(:db)}'")
      l = Listing.where("created_at > '#{time_frame.to_formatted_s(:db)}'")
      m = Message.where("created_at > '#{time_frame.to_formatted_s(:db)}'")
      t = Conversation.where("updated_at > '#{time_frame.to_formatted_s(:db)}' AND status = 'accepted'")
    end
    
    return [c.collect(&:author_id), l.collect(&:author_id), m.collect(&:sender_id), t.collect(&:participants).flatten.collect(&:id)].flatten.uniq.count
  end
end

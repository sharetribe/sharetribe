class StatisticsController < ApplicationController

  skip_filter :single_community_only, :dashboard_only
  
  layout 'dashboard'
  
  
  def index
    
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
    @activation_p_first_two_weeks = (@active_in_first_two_weeks*1.0 / @total_users_for_first_two_weeks * 100).round(2)
    
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
    @transaction_p_first_month = (@transaction_in_first_month*1.0 / @total_users_for_first_month * 100).round(2)
    
    
    #retention
    @registered_users = Person.count
    #CommunityMembership.where("last_page_load_date > ?", 1.months.ago).select("distinct(person_id)").uniq  #uniq not working as hoped here, so use SQL
    @mau = CommunityMembership.find_by_sql("select distinct person_id from community_memberships where last_page_load_date > '#{1.month.ago.to_formatted_s(:db)}'").count
    @wau = CommunityMembership.find_by_sql("select distinct person_id from community_memberships where last_page_load_date > '#{7.days.ago.to_formatted_s(:db)}'").count
    @dau = CommunityMembership.find_by_sql("select distinct person_id from community_memberships where last_page_load_date > '#{25.hours.ago.to_formatted_s(:db)}'").count

    @mau_p = ((@mau*1.0/@registered_users)*100).round(2)
    @wau_p = ((@wau*1.0/@registered_users)*100).round(2)
    @dau_p = ((@dau*1.0/@registered_users)*100).round(2)


    #referral
    @inv_sent = Invitation.where("inviter_id is not NULL").count
    @inv_accepted = Invitation.where("inviter_id is not NULL and usages_left = 0").count
    @inv_accepted_avg = @inv_accepted*1.0 / @registered_users
    @inv_sent_avg = @inv_sent*1.0 / @registered_users
    

    #revenue
    @revenue_sum = 0
    Community.select(:monthly_price_in_euros).each do |d|
      @revenue_sum += d.monthly_price_in_euros if d.monthly_price_in_euros
    end

  end
end
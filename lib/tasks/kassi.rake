namespace :kassi do

  desc "Calculates statistics and stores to DB for all communties where member count is over the minimum level."
  task :calculate_statistics => :environment do |t, args|

    MIN_MEMBER_COUNT_TO_CALCULATE_STATISTICS = 10

    #Calculate statistics for the whole server
    Statistic.create

    # And for all communities bigger than the minimum size
    Community.all.each do |community|
      if community.members.count >= MIN_MEMBER_COUNT_TO_CALCULATE_STATISTICS
        Statistic.create(:community => community)
      end
    end

  end

end

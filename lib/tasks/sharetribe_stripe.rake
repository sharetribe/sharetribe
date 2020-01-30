namespace :sharetribe do
  namespace :stripe do
    namespace :capabilites do
      def confirm!(message)
        print "#{message} (yes/no) "
        $stdout.flush
        input = $stdin.gets.chomp
        unless input == 'yes'
          raise "Task aborted."
        end
      end

      desc "Updates capabilities of person"
      task :update_person, [:person_id] => [:environment] do |t, args|
        person_id = args[:person_id]
        capabilities_update = StripeService::CapabilitiesUpdate.new(person_id: person_id)
        capabilities_update.update
      end

      task :update_marketplace_page_1 do
        capabilities_update = @capabilities_update_class.new(community_id: @marketplace_id, page: 1)
        capabilities_update.update
      end

      task :update_marketplace_page_2 do
        capabilities_update = @capabilities_update_class.new(community_id: @marketplace_id, page: 2)
        capabilities_update.update
      end

      task :update_marketplace_page_3 do
        capabilities_update = @capabilities_update_class.new(community_id: @marketplace_id, page: 3)
        capabilities_update.update
      end

      task :update_marketplace_page_4 do
        capabilities_update = @capabilities_update_class.new(community_id: @marketplace_id, page: 4)
        capabilities_update.update
      end

      multitask update_marketplace_main: [:update_marketplace_page_1, :update_marketplace_page_2, :update_marketplace_page_3, :update_marketplace_page_4]

      desc "Updates capabilities of marketplace"
      task :update_marketplace, [:marketplace_id] => [:environment] do |t, args|
        @marketplace_id = args[:marketplace_id]
        confirm!("Are you sure you want to update all stripe accounts for this marketplace id='#{@marketplace_id}'?")

        @capabilities_update_class = StripeService::CapabilitiesUpdate
        Rake::Task["sharetribe:stripe:capabilites:update_marketplace_main"].invoke
      end

      task :update_all_page_1 do
        capabilities_update = @capabilities_update_class.new(update_all: true, page: 1)
        capabilities_update.update
      end

      task :update_all_page_2 do
        capabilities_update = @capabilities_update_class.new(update_all: true, page: 2)
        capabilities_update.update
      end

      task :update_all_page_3 do
        capabilities_update = @capabilities_update_class.new(update_all: true, page: 3)
        capabilities_update.update
      end

      task :update_all_page_4 do
        capabilities_update = @capabilities_update_class.new(update_all: true, page: 4)
        capabilities_update.update
      end

      multitask update_all_main: [:update_all_page_1, :update_all_page_2, :update_all_page_3, :update_all_page_4]

      desc "Updates capabilities of whole project"
      task :update_all => :environment do
        confirm!("Are you sure you want to update all stripe accounts of all customers of all merketplaces?")

        @capabilities_update_class = StripeService::CapabilitiesUpdate
        Rake::Task["sharetribe:stripe:capabilites:update_all_main"].invoke
      end
    end
  end
end

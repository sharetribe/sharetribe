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

      desc "Updates capabilities of marketplace"
      task :update_marketplace, [:marketplace_id] => [:environment] do |t, args|
        marketplace_id = args[:marketplace_id]
        confirm!("Are you sure you want to update all stripe accounts for this marketplace id='#{marketplace_id}'?")

        capabilities_update = StripeService::CapabilitiesUpdate.new(community_id: marketplace_id)
        capabilities_update.update
      end

      desc "Updates capabilities of whole project"
      task :update_all => :environment do
        confirm!("Are you sure you want to all stripe accounts of all customers of all merketplaces?")

        capabilities_update = StripeService::CapabilitiesUpdate.new(update_all: true)
        capabilities_update.update
      end
    end
  end
end

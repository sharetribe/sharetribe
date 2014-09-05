module MarketplaceService
  module Person
    PersonModel = ::Person

    module Entity
      # module_function
    end

    module Command

      module_function

      def unsubscribe_email_from_community_updates(email_address)
        person = Maybe(Email.find_by_address(email_address)).person.or_else(nil)
        Helper.unsubscribe_from_community_updates(person)
      end

      def unsubscribe_person_from_community_updates(person_id)
        person = Person.find_by_id(person_id)
        Helper.unsubscribe_from_community_updates(person)
      end

      module Helper
        module_function

        def unsubscribe_from_community_updates(person)
          unless person.nil?
            person.min_days_between_community_updates = 100000
            person.save!
          end
        end
      end
    end

    module Query
      # module_function
    end
  end
end

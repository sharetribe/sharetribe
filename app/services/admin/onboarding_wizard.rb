module Admin
  class OnboardingWizard

    MarketplaceSetupSteps = ::MarketplaceSetupSteps

    KNOWN_STATUSES = [
      :slogan_and_description, :cover_photo, :filter, :paypal, :listing, :invitation
    ].to_set

    EVENT_TYPES = [
      :community_customizations_updated, :community_updated
    ].to_set

    SetupStatus = EntityUtils.define_builder(
      [:community_id, :fixnum, :mandatory],
      [:slogan_and_description, :bool, :mandatory],
      [:cover_photo, :bool, :mandatory],
      [:filter, :bool, :mandatory],
      [:paypal, :bool, :mandatory],
      [:listing, :bool, :mandatory],
      [:invitation, :bool, :mandatory])

    def initialize(community_id)
      @community_id = community_id
    end

    # Get the status as a SetupStatus hash
    def setup_status
      load_setup_status(@community_id)
    end

    # Imperative shell. Process the given event_type with *args
    # arguments. If the event leads to a state change apply it and
    # return true. Otherwise return false.
    def update_from_event(event_type, *args)
      setup_status = load_setup_status(@community_id)
      completed_status = process_event(event_type, setup_status, args)

      if completed_status
        update_completed(@community_id, completed_status)
        true
      else
        false
      end
    end


    private

    def process_event(event_type, setup_status, args)
      unless EVENT_TYPES.include?(event_type)
        raise ArgumentError.new("Unkown event type: #{event_type}")
      end

      # Dispatch to event handler method of same name as event_type
      method(event_type).call(setup_status, *args)
    end

    # Update events

    def community_customizations_updated(setup_status, community_customizations)
      if !setup_status[:slogan_and_description] &&
         community_customizations.all? { |c| c.slogan.present? } &&
         community_customizations.all? { |c| c.description.present? }
        :slogan_and_description
      end
    end

    def community_updated
    end

    def filter_created
    end

    def paypal_connected
    end

    def listing_created
    end

    def invitation_created
    end

    def load_setup_status(community_id)
      m = Maybe(MarketplaceSetupSteps.find_by(community_id: community_id))
          .or_else { MarketplaceSetupSteps.new(community_id: community_id) }

      to_setup_status(m)
    end

    def update_completed(community_id, status)
      unless KNOWN_STATUSES.include?(status)
        raise ArgumentError.new("Unkown status: #{status}")
      end

      m = MarketplaceSetupSteps.find_or_create_by(community_id: community_id)
      m.update(status => true)
    end

    def to_setup_status(model)
      SetupStatus.call(EntityUtils.model_to_hash(model))
   end
  end
end

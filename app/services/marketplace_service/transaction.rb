module MarketplaceService
  module Transaction
    TransactionModel = ::Transaction

    module Entity
      Listing = Struct.new(
        :id,
        :title,
        :author_id,
        :price,
        :quantity
      )

      Transaction = Struct.new(
        :id,
        :last_transition,
        :last_transition_at,
        :listing,
        :direction, # :offer or :request
        :status,
        :author_skipped_feedback,
        :starter_skipped_feedback,
        :starter_id,
        :testimonials,
        :transitions,
        :payment_sum,
        :conversation,
        :booking,
        :__model
      )

      Transition = Struct.new(
        :to_state,
        :created_at
      )

      Testimonial = Struct.new(
        :author_id,
        :receiver_id,
        :grade
      )

      ConversationEntity = MarketplaceService::Conversation::Entity
      Conversation = ConversationEntity::Conversation
      ConversationParticipant = ConversationEntity::ConversationParticipant

      module_function

      def waiting_testimonial_from?(transaction, person_id)
        if transaction[:starter_id] == person_id
          if transaction[:starter_skipped_feedback]
            false
          else
            testimonial_from(transaction, person_id).nil?
          end
        else
          if transaction[:author_skipped_feedback]
            false
          else
            testimonial_from(transaction, person_id).nil?
          end
        end
      end

      def testimonial_from(transaction, person_id)
        transaction[:testimonials].select { |testimonial| testimonial[:author_id] == person_id }
      end

      def transaction(transaction_model)
        listing_model = transaction_model.listing
        # TODO Add Listing service
        listing = EntityUtils.from_hash(Listing,
          EntityUtils.model_to_hash(transaction_model.listing).merge(author_id: listing_model.author.id).merge(price: listing_model.price))

        EntityUtils.from_hash(Transaction, EntityUtils.model_to_hash(transaction_model).merge({
          status: transaction_model.transaction_transitions.last.to_state,
          last_transition_at: transaction_model.transaction_transitions.last.created_at,
          listing: listing,
          testimonials: transaction_model.testimonials.map { |testimonial|
            EntityUtils.from_hash(Testimonial, EntityUtils.model_to_hash(testimonial))
          },
          starter_id: transaction_model.starter.id,
          transitions: transaction_model.transaction_transitions.map { |transition|
            EntityUtils.from_hash(Transition, EntityUtils.model_to_hash(transition))
          },
          direction: listing_model.transaction_type.direction.to_sym,
          payment_sum: Maybe(transaction_model).payment.total_sum.or_else { nil },
          booking: transaction_model.booking,
          __model: transaction_model
        }))
      end

      def transaction_with_conversation(transaction_model)
        transaction = Entity.transaction(transaction_model)
        transaction.conversation = ConversationEntity.conversation(transaction_model.conversation)
        transaction
      end
    end

    module Command
      module_function
    end

    module Query

      module_function

      def transaction_with_conversation(transaction_id, person_id, community_id)
        transaction_model = TransactionModel.joins(:listing)
          .where(id: transaction_id)
          .where(community_id: community_id)
          .includes(:booking)
          .where("starter_id = ? OR listings.author_id = ?", person_id, person_id)
          .first

        Entity.transaction_with_conversation(transaction_model)
      end
    end
  end
end

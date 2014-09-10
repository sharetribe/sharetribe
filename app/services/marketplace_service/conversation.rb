module MarketplaceService
  module Conversation
    ConversationModel = ::Conversation

    module Entity
      Conversation = Struct.new(
        :id,
        :participants,
        :messages,
        :transaction,
        :listing
      )

      module_function

      def conversation_title(conversation)
        last_message = conversation[:messages].last

        if conversation[:transaction].present?
          if last_message[:created_at] > conversation[:transaction][:last_transition_at]
            last_message[:content]
          else
            conversation[:transaction].status
          end
        else
          last_message[:content]
        end
      end

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

      def last_update_at(conversation)
        last_message = conversation[:messages].last

        if conversation[:transaction].present?
          if last_message[:created_at] > conversation[:transaction][:last_transition_at]
            last_message[:created_at]
          else
            conversation[:transaction][:last_transition_at]
          end
        else
          last_message[:created_at]
        end
      end

      def testimonial_from(transaction, person_id)
        transaction[:testimonials].select { |testimonial| testimonial[:author_id] == person_id }
      end

      # TODO Add person entity, and split this
      ConversationParticipant = Struct.new(
        :id,
        :username,
        :name,
        :avatar,
        :is_read,
        :is_starter
      )

      Listing = Struct.new(
        :id,
        :title,
        :author_id
      )

      Transaction = Struct.new(
        :id,
        :last_transition,
        :last_transition_at,
        :listing,
        :status,
        :author_skipped_feedback,
        :starter_skipped_feedback,
        :starter_id,
        :testimonials
      )

      Message = Struct.new(
        :sender_id,
        :content,
        :created_at
      )

      Testimonial = Struct.new(
        :author_id,
        :receiver_id,
        :grade
      )

      module_function

      def conversation(conversation_model)
        h = {id: conversation_model.id}

        h[:participants] = conversation_model.participations.map do |participation|
          participant = participation.person
          EntityUtils.from_hash(ConversationParticipant, {
            id: participant.id,
            username: participant.username,
            name: participant.name,
            avatar: participant.image.url(:thumb),
            is_read: participation.is_read,
            is_starter: participation.is_starter})
        end

        h[:messages] = conversation_model.messages.map do |message|
          EntityUtils.from_hash(Message, EntityUtils.model_to_hash(message))
        end

        EntityUtils.from_hash(Conversation, h)
      end

      def conversation_with_transaction(conversation_model)
        conversation_entity = conversation(conversation_model)
        conversation_entity.transaction = transaction(conversation_model.transaction) if conversation_model.transaction.present?
        conversation_entity
      end

      def transaction(transaction_model)
        listing = EntityUtils.from_hash(Listing,
          EntityUtils.model_to_hash(transaction_model.listing).merge(author_id: transaction_model.listing.id))

        EntityUtils.from_hash(Transaction, EntityUtils.model_to_hash(transaction_model).merge({
          status: transaction_model.transaction_transitions.last.to_state,
          last_transition_at: transaction_model.transaction_transitions.last.created_at,
          listing: listing,
          testimonials: transaction_model.testimonials.map { |testimonial|
            EntityUtils.from_hash(Testimonial, EntityUtils.model_to_hash(testimonial))
          },
          starter_id: transaction_model.starter.id,
        }))

      end
    end

    module Command
      module_function
    end

    module Query

      module_function

      def conversations_and_transactions(person_id, community_id, pagination_opts = {})
        conversations = ConversationModel.joins(:participations)
          .where( { participations: { person_id: person_id }} )
          .where(community_id: community_id)
          .includes(:transaction)
          .order("last_message_at DESC")

        conversations = if pagination_opts[:per_page].present? && pagination_opts[:page].present?
          conversations.paginate(per_page: pagination_opts[:per_page], page: pagination_opts[:page])
        else
          conversations
        end

        conversations.map do |conversation_model|
          Entity.conversation_with_transaction(conversation_model)
        end
      end
    end
  end
end

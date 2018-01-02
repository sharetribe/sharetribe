module MarketplaceService
  module Conversation
    ConversationModel = ::Conversation
    ParticipationModel = ::Participation
    PersonModel = ::Person
    PersonEntity = MarketplaceService::Person::Entity

    module Entity
      Conversation = EntityUtils.define_entity(
        :id,
        :messages,
        :transaction,
        :listing,
        :created_at,
        :last_message_at,
        :starter_person,
        :other_person,
        :starting_page
      )

      Message = EntityUtils.define_entity(
        :sender,
        :content,
        :created_at
      )

      TransactionEntity = MarketplaceService::Transaction::Entity
      Transaction = TransactionEntity::Transaction
      Transition = TransactionEntity::Transition
      Testimonial = TransactionEntity::Testimonial

      module_function

      def conversation(conversation_model, community_id)
        Conversation[{
          id: conversation_model.id,
          listing: conversation_model.listing,
          transaction: conversation_model.tx,
          messages: messages(conversation_model.messages, community_id),
          created_at: conversation_model.created_at,
          last_message_at: conversation_model.last_message_at,
          starter_person: PersonEntity.person(conversation_model.starter, community_id),
          other_person: PersonEntity.person(conversation_model.other_party(conversation_model.starter), community_id),
          starting_page: conversation_model.starting_page
        }]
      end

      def deleted_conversation_placeholder
        Conversation[{
          last_transition_at: :not_available,
          metadata: "this is a placeholder for conversation that was deleted, probably due a participant deleting his profile."
        }]
      end

      def messages(message_models, community_id)
        message_models
          .reject { |msg|
            # We should be able to get rid of this soon. Previously, blank content meant that the message was abount a
            # transaction transition. However, currently the transitions are separated from messages
            msg.content.blank?
          }
          .map { |msg| message(msg, community_id) }
      end

      def message(message_model, community_id)
        Message[{
          sender: PersonEntity.person(message_model.sender, community_id),
          content: message_model.content,
          created_at: message_model.created_at
        }]
      end
    end

    module Command
      module_function

      def mark_as_read(conversation_id, person_id)
        CommandHelper.get_participation_relation(conversation_id, person_id).update_all({is_read: true})
      end

      def mark_as_unread(conversation_id, person_id)
        CommandHelper.get_participation_relation(conversation_id, person_id).update_all({is_read: false})
      end
    end

    module CommandHelper
      module_function

      def get_participation_relation(conversation_id, person_id)
        ParticipationModel
          .where({conversation_id: conversation_id })
          .where({ person_id: person_id })
      end
    end

    module Query

      module_function

      def conversation_for_person(conversation_id, person_id, community_id)
        conversation = conversations_for_person(person_id, community_id)
          .where({id: conversation_id})
          .first

        if conversation
          Entity.conversation(conversation, community_id)
        else
          nil
        end
      end

      def conversations_for_person(person_id, community_id)
        ConversationModel.joins(:participations)
          .where( { participations: { person_id: person_id }} )
          .where(community_id: community_id)
      end

      def latest_messages_for_conversations(conversation_ids)
        return [] if conversation_ids.empty?
        Message.by_converation_ids(conversation_ids).latest_for_conversation
          .map{|m| [m.conversation_id, [m.content, m.created_at]]}.to_h
      end

      def conversations_for_community(community_id, sort_field, sort_direction, limit, offset)
        conversations = ConversationModel.non_payment_or_free(community_id)
          .order("#{sort_field} #{sort_direction}").limit(limit).offset(offset)
        conversations.map{|conversation| Entity.conversation(conversation, community_id) }
      end

      def count_for_community(community_id)
        ConversationModel.non_payment_or_free(community_id).count
      end
    end
  end
end

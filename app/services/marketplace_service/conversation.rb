module MarketplaceService
  module Conversation
    ConversationModel = ::Conversation
    ParticipationModel = ::Participation

    module Entity
      Conversation = EntityUtils.define_entity(
        :id,
        :participants,
        :messages,
        :transaction,
        :listing,
        :last_message_at
      )

      ConversationParticipant = EntityUtils.define_entity(
        :person,
        :is_read,
        :is_starter,
      )

      Message = EntityUtils.define_entity(
        :sender,
        :content,
        :created_at
      )

      TransactionEntity = MarketplaceService::Transaction::Entity
      Listing = TransactionEntity::Listing
      Transaction = TransactionEntity::Transaction
      Transition = TransactionEntity::Transition
      Testimonial = TransactionEntity::Testimonial
      PersonEntity = MarketplaceService::Person::Entity

      module_function

      def participant_by_id(conversation, person_id)
        conversation[:participants]
          .select { |participant| participant[:person][:id] == person_id }
          .map { |participant| participant[:person] }
          .first
      end

      def other_by_id(conversation, person_id)
        conversation[:participants]
          .reject { |participant| participant[:person][:id] == person_id }
          .map { |participant| participant[:person] }
          .first
      end

      def conversation(conversation_model)
        Conversation[{
          id: conversation_model.id,
          participants: participations(conversation_model.participations),
          listing: conversation_model.listing,
          messages: messages(conversation_model.messages),
          last_message_at: conversation_model.last_message_at
        }]
      end

      def participations(participation_models)
        participation_models.map { |participation_model| participation(participation_model) }
      end

      def participation(participation_model)
        ConversationParticipant[{
          person: PersonEntity.person(participation_model.person),
          is_read: participation_model.is_read,
          is_starter: participation_model.is_starter
        }]
      end

      def messages(message_models)
        message_models
          .reject { |msg|
            # We should be able to get rid of this soon. Previously, blank content meant that the message was abount a
            # transaction transition. However, currently the transitions are separated from messages
            msg.content.blank?
          }
          .map { |msg| message(msg) }
      end

      def message(message_model)
        Message[{
          sender: PersonEntity.person(message_model.sender),
          content: message_model.content,
          created_at: message_model.created_at
        }]
      end

      def conversation_with_transaction(conversation_model)
        conversation_entity = conversation(conversation_model)
        conversation_entity[:transaction] = TransactionEntity.transaction(conversation_model.transaction) if conversation_model.transaction.present?
        conversation_entity
      end
    end

    module Command
      module_function

      def mark_as_read(conversation_id, person_id)
        conversation = ParticipationModel
          .where({conversation_id: conversation_id })
          .where({ person_id: person_id })
          .first
          .update_attributes({is_read: true})
      end
    end

    module Query

      module_function

      def conversation_and_transaction_count(person_id, community_id)
        conversations_and_transaction_relation(person_id, community_id)
          .count
      end

      def conversation_for_person(conversation_id, person_id, community_id)
        conversation = conversations_for_person(person_id, community_id)
          .where({id: conversation_id})
          .first

        if conversation
          Entity.conversation_with_transaction(conversation)
        else
          nil
        end
      end

      def conversations_and_transaction_relation(person_id, community_id)
        conversations_for_person(person_id, community_id)
          .includes(:transaction)
          .order("last_message_at DESC")
      end

      def conversations_for_person(person_id, community_id)
        ConversationModel.joins(:participations)
          .where( { participations: { person_id: person_id }} )
          .where(community_id: community_id)
      end

      def conversations_and_transactions_for_person_sorted_by_activity(person_id, community_id, limit, offset)
        sql = sql_for_conversations_for_community_sorted_by_activity(person_id, community_id, limit, offset)
        conversations = ConversationModel.find_by_sql(sql)

        conversations.map { |conversation|
          Entity.conversation_with_transaction(conversation)
        }
      end

      def transactions_count_for_community(community_id)
        TransactionModel.where(:community_id => community_id).count
      end

      def sql_for_conversations_for_community_sorted_by_activity(person_id, community_id, limit, offset)
        "
          SELECT conversations.* FROM conversations

          # Join transactions and participations
          LEFT JOIN transactions ON transactions.conversation_id = conversations.id
          JOIN participations ON participations.conversation_id = conversations.id

          # Join the 'last_transition_at'
          JOIN (
            SELECT tt1.transaction_id, tt1.created_at as last_transition_at, tt1.to_state as last_transition_to
            FROM transaction_transitions tt1
            LEFT JOIN transaction_transitions tt2 ON tt1.transaction_id = tt2.transaction_id AND tt1.created_at < tt2.created_at
            WHERE tt2.id IS NULL
          ) AS tt ON (transactions.id = tt.transaction_id)

          # Where person and community
          WHERE conversations.community_id = '#{community_id}'
          AND participations.person_id = '#{person_id}'

          # Order by 'last_activity', that is last message or last transition
          ORDER BY GREATEST(COALESCE(last_transition_at, 0), COALESCE(conversations.last_message_at, 0)) DESC

          # Pagination
          LIMIT #{limit} OFFSET #{offset}
        "
      end
    end
  end
end

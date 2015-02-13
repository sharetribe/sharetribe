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
        :last_message_at,
        :starter_person,
        :other_person
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
          messages: messages(conversation_model.messages, community_id),
          last_message_at: conversation_model.last_message_at,
          starter_person: PersonEntity.person(conversation_model.starter, community_id),
          other_person: PersonEntity.person(conversation_model.other_party(conversation_model.starter), community_id)
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

        connection = ActiveRecord::Base.connection

        message_sql = SQLUtils.ar_quote(connection, @construct_last_message_content_sql, conversation_ids: conversation_ids)
        latest_messages = connection.execute(message_sql).reduce({}) { |memo, (id, conversation_id, content, created_at)|
          _, memo_id, memo_at = memo[conversation_id]
          if( memo_at.nil? || memo_at < created_at || memo_id < id)
            memo[conversation_id] = [content, id, created_at]
          end
          memo
        }

        HashUtils.map_values(latest_messages) { |(content, _, at)| [content, at] }
      end

      @construct_last_message_content_sql = ->(params){
        "
          SELECT id, conversation_id, content, created_at FROM messages WHERE conversation_id in (#{params[:conversation_ids].join(',')})
        "
      }
    end
  end
end

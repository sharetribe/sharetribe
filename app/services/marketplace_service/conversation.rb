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

      def conversation(conversation_model)
        Conversation[{
          id: conversation_model.id,
          listing: conversation_model.listing,
          messages: messages(conversation_model.messages),
          last_message_at: conversation_model.last_message_at,
          starter_person: PersonEntity.person(conversation_model.starter),
          other_person: PersonEntity.person(conversation_model.other_party(conversation_model.starter))
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
          Entity.conversation(conversation)
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
        connection.execute(message_sql).reduce({}) { |memo, (conversation_id, content, created_at)|
          _, memo_at = memo[conversation_id]
          if( memo_at.nil? || memo_at < created_at)
            memo[conversation_id] = [content, created_at]
          end
          memo
        }
      end

      @construct_last_message_content_sql = ->(params){
        "
          SELECT conversation_id, content, created_at FROM messages WHERE conversation_id in (#{params[:conversation_ids].join(',')})
        "
      }
    end
  end
end

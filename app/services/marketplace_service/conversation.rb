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

      conversation_fields = [
        [:title, :string, :mandatory],
        [:last_update_at, :string, :mandatory],
        [:path, :string, :mandatory],
        [:other_party, :hash, :mandatory],
        [:is_read, :bool, :mandatory]
      ]

      transasction_fields = [
        [:listing_title, :string, :mandatory],
        [:listing_url, :string, :mandatory],
        [:is_author, :bool, :mandatory],
        [:waiting_feedback_from_current, :mandatory],
        [:transaction_status, :string, :mandatory]
      ]

      InboxRowConversation = EntityUtils.define_builder(*conversation_fields)
      InboxRowTransaction = EntityUtils.define_builder(*conversation_fields, *transasction_fields)

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
        get_participation_relation(conversation_id, person_id).update_all({is_read: true})
      end

      def mark_as_unread(conversation_id, person_id)
        get_participation_relation(conversation_id, person_id).update_all({is_read: false})
      end

      def get_participation_relation(conversation_id, person_id)
        ParticipationModel
          .where({conversation_id: conversation_id })
          .where({ person_id: person_id })
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

      # conversation_fields = [
      #   [:title, :string, :mandatory],              # Last message content, OR last transaction
      #   [:last_update_at, :string, :mandatory],     # Last message at, OR last transaction at
      #   [:other_party, :hash, :mandatory],          # Participant, which is not current user
      #   [:is_read, :bool, :mandatory]               # select is_read FROM participation where author_id = #{current_user.id}
      # ]

      # transasction_fields = [
      #   [:listing_title, :string, :mandatory],          # select title FROM listing
      #   [:is_author, :bool, :mandatory],                # select author_id FROM listing
      #   [:waiting_feedback_from_current, :mandatory],   # select author_skipped_feedback, starter_skipped_feedback FROM transaction
                                                          # select * FROM testimonials WHERE author_id = #{current_user.id}
      #   [:transaction_status, :string, :mandatory]      # Last from transaction
      # ]

      def inbox_data(person_id, community_id, limit, offset)
        sql = sql_for_conversations_for_community_sorted_by_activity(person_id, community_id, limit, offset)

        result_hash = ActiveRecord::Base.connection.execute(sql).each(as: :hash)
      end

      def transactions_count_for_community(community_id)
        TransactionModel.where(:community_id => community_id).count
      end

      def sql_for_conversations_for_community_sorted_by_activity(person_id, community_id, limit, offset)
        "
          SELECT
            m.last_message_at,
            m.last_message_content,
            tt.last_transition_at,
            tt.last_transition_to_state,
            GREATEST(COALESCE(tt.last_transition_at, 0), COALESCE(m.last_message_at, 0)) as last_activity_at,
            listings.id as listing_id,
            listings.title as listing_title,
            listings.author_id as author_id,
            transactions.author_skipped_feedback as author_skipped_feedback,
            transactions.starter_skipped_feedback as starter_skipped_feedback
          FROM conversations

          # Join transactions and participations
          LEFT JOIN transactions ON transactions.conversation_id = conversations.id

          # Join listing
          LEFT JOIN listings ON transactions.listing_id = listings.id

          # Join testimonial from current
          LEFT JOIN testimonials ON (testimonials.transaction_id = transactions.id AND testimonials.author_id = '#{person_id}')

          # Get 'last_transition_at' and 'last_transition_to_state'
          # (this is done by joining the transitions table to itself where created_at < created_at OR sort_key < sort_key, if created_at equals)
          LEFT JOIN (
            SELECT tt1.transaction_id, tt1.created_at as last_transition_at, tt1.to_state as last_transition_to_state
            FROM transaction_transitions tt1
            LEFT JOIN transaction_transitions tt2 ON tt1.transaction_id = tt2.transaction_id AND (tt1.created_at < tt2.created_at OR tt1.sort_key < tt2.sort_key)
            WHERE tt2.id IS NULL
          ) AS tt ON (transactions.id = tt.transaction_id)

          # Get 'last_message_at' and 'last_message_content'
          # (this is done by joining the messages table to itself where created_at < created_at)
          LEFT JOIN (
            SELECT m1.conversation_id, m1.created_at as last_message_at, m1.content as last_message_content
            FROM messages m1
            LEFT JOIN messages m2 ON m1.conversation_id = m2.conversation_id AND m1.created_at < m2.created_at
            WHERE m2.id IS NULL
          ) AS m ON (conversations.id = m.conversation_id)

          LEFT JOIN participations AS starter_participation ON starter_participation.conversation_id = conversations.id AND starter_participation.is_starter = true
          LEFT JOIN participations AS other_participation ON other_participation.conversation_id = conversations.id AND other_participation.is_starter = false
          LEFT JOIN people AS starter_person ON starter_person.id = starter_participation.person_id
          LEFT JOIN people AS other_person ON other_person.id = other_participation.person_id

          # Where person and community
          WHERE conversations.community_id = #{community_id}
          AND (starter_participation.person_id = '#{person_id}') OR (other_participation.person_id = '#{person_id}')

          # Order by 'last_activity_at', that is last message or last transition
          ORDER BY last_activity_at DESC

          # Pagination
          LIMIT #{limit} OFFSET #{offset}
        "
      end
    end
  end
end

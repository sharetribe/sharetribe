module MarketplaceService
  module Transaction
    EntityUtils = MarketplaceService::EntityUtils
    TransactionModel = ::Transaction

    module Entity
      Listing = EntityUtils.define_entity(
        :id,
        :title,
        :author_id,
        :price,
        :quantity
      )

      Transaction = EntityUtils.define_entity(
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

      Transition = EntityUtils.define_entity(
        :to_state,
        :created_at
      )

      Testimonial = EntityUtils.define_entity(
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
        transaction[:testimonials].find { |testimonial| testimonial[:author_id] == person_id }
      end

      def transaction(transaction_model)
        listing_model = transaction_model.listing
        # TODO Add Listing service
        listing = Listing[
          EntityUtils.model_to_hash(transaction_model.listing)
            .merge(author_id: listing_model.author.id)
            .merge(price: listing_model.price)]

        Transaction[EntityUtils.model_to_hash(transaction_model).merge({
          status: transaction_model.transaction_transitions.last.to_state,
          last_transition_at: transaction_model.transaction_transitions.last.created_at,
          listing: listing,
          testimonials: transaction_model.testimonials.map { |testimonial|
            Testimonial[EntityUtils.model_to_hash(testimonial)]
          },
          starter_id: transaction_model.starter.id,
          transitions: transaction_model.transaction_transitions.map { |transition|
            Transition[EntityUtils.model_to_hash(transition)]
          },
          direction: listing_model.transaction_type.direction.to_sym,
          payment_sum: Maybe(transaction_model).payment.total_sum.or_else { nil },
          booking: transaction_model.booking,
          __model: transaction_model
        })]
      end

      def transaction_with_conversation(transaction_model)
        transaction = Entity.transaction(transaction_model)
        transaction[:conversation] = ConversationEntity.conversation(transaction_model.conversation)
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

      def transactions_sorted_by_column_for_community(community_id, sort_column, sort_direction, pagination_opts = {})
        conversations = TransactionModel
          .where(:community_id => community_id)
          .includes(:listing)
          .paginate(:page => pagination_opts[:page], :per_page => pagination_opts[:per_page])
          .order("#{sort_column} #{sort_direction}")
      end

      def transactions_sorted_by_activity_for_community(community_id, sort_direction, pagination_opts = {})
        pagination = parse_pagination_opts(pagination_opts)

        transaction_model = WillPaginate::Collection.create(pagination[:page], pagination[:per_page], TransactionModel.count) do |pager|
          pager.replace(TransactionModel
            .find_by_sql("
              SELECT * from transactions t
              JOIN (
                SELECT tt1.transaction_id, tt1.created_at as last_transition_at, tt1.to_state as last_transition_to
                FROM transaction_transitions tt1
                LEFT JOIN transaction_transitions tt2 ON tt1.transaction_id = tt2.transaction_id AND tt1.created_at < tt2.created_at
                WHERE tt2.id IS NULL
              ) AS tt ON (t.id = tt.transaction_id)
              JOIN conversations ON t.conversation_id = conversations.id
              WHERE t.community_id = #{community_id}
              ORDER BY GREATEST(last_transition_at, conversations.last_message_at) #{sort_direction}
              LIMIT #{pagination[:limit]} OFFSET #{pagination[:offset]}
            "))
        end
      end

      def parse_pagination_opts(pagination_opts = {})
        per_page = Maybe(pagination_opts)[:per_page].to_i.or_else(30)
        page = Maybe(pagination_opts)[:page].to_i.or_else(1)

        {
          per_page: per_page,
          page: page,
          limit: per_page,
          offset: per_page * (page - 1)
        }
      end
    end
  end
end

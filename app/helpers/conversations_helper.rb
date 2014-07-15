module ConversationsHelper

  def get_message_title(listing)
    listing.title
  end

  def icon_for(status)
    case status
    when "accepted"
      "ss-check"
    when "confirmed"
      "ss-check"
    when "rejected"
      "ss-delete"
    when "canceled"
      "ss-delete"
    when "paid"
      "ss-check"
    when "preauthorized"
      "ss-check"
    end
  end

  def path_for_status_link(status, conversation, current_user)
    case status
    when "accept"
      accept_person_message_path(current_user, :id => conversation.id.to_s)
    when "confirm"
      confirm_person_message_path(current_user, :id => conversation.id.to_s)
    when "reject"
      reject_person_message_path(@current_user, :id => conversation.id.to_s)
    when "cancel"
      cancel_person_message_path(@current_user, :id => conversation.id.to_s)
    when "accept_preauthorized"
      accept_preauthorized_person_message_path(current_user, :id => conversation.id.to_s)
    when "reject_preauthorized"
      reject_preauthorized_person_message_path(@current_user, :id => conversation.id.to_s)
    end
  end

  def free_conversation?
    params[:message_type] || (@listing && @listing.transaction_type.is_inquiry?)
  end

  # Give `status`, `is_author` and `other_party` and get back icon and text for current status
  def conversation_icon_and_status(status, is_author, other_party, waiting_feedback)
    icon_waiting_you = icon_tag("alert", ["icon-fix-rel", "waiting-you"])
    icon_waiting_other = icon_tag("clock", ["icon-fix-rel", "waiting-other"])

    # Split "confirmed" status into "waiting_feedback" and "completed"
    status = if waiting_feedback
      "waiting_feedback"
    else
      "completed"
    end if status == "confirmed"

    status_hash = {
      pending: {
        author: {
          icon: icon_waiting_you,
          text: t("conversations.status.waiting_for_you_to_accept_request")
        },
        starter: {
          icon: icon_waiting_other,
          text: t("conversations.status.waiting_for_listing_author_to_accept_request", listing_author_name: other_party.name)
        }
      },

      preauthorized: {
        author: {
          icon: icon_waiting_you,
          text: t("conversations.status.waiting_for_you_to_accept_request")
        },
        starter: {
          icon: icon_waiting_other,
          text: t("conversations.status.waiting_for_listing_author_to_accept_request", listing_author_name: other_party.name)
        }
      },

      accepted: {
        author: {
          icon: icon_waiting_other,
          text: t("conversations.status.waiting_payment_from_requester", requester_name: other_party.name)
        },
        starter: {
          icon: icon_waiting_you,
          text: t("conversations.status.waiting_payment_from_you")
        }
      },

      rejected: {
        both: {
          icon: icon_tag("cross", ["icon-fix-rel", "rejected"]),
          text: t("conversations.status.request_rejected")
        }
      },

      paid: {
        author: {
          icon: icon_waiting_other,
          text: t("conversations.status.waiting_confirmation_from_requester", requester_name: other_party.name)
        },
        starter: {
          icon: icon_waiting_you,
          text: t("conversations.status.waiting_confirmation_from_you")
        }
      },

      waiting_feedback: {
        both: {
          icon: icon_waiting_you,
          text: t("conversations.status.waiting_feedback_from_you")
        }
      },

      completed: {
        both: {
          icon: icon_tag("check", ["icon-fix-rel", "confirmed"]),
          text: t("conversations.status.request_confirmed")
        }
      },

      canceled: {
        both: {
          icon: icon_tag("cross", ["icon-fix-rel", "canceled"]),
          text: t("conversations.status.request_canceled")
        }
      }
    }

    Maybe(status_hash)[status.to_sym]
      .map { |s| Maybe(is_author ? s[:author] : s[:starter]).or_else { s[:both] } }
      .values
      .get
  end
end

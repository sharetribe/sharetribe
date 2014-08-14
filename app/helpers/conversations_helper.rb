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

  #
  # Returns statuses in Hash format
  # statuses = [
  #   {
  #     type: :status_info,
  #     content: {
  #       info_text_part: 'msg',
  #       info_icon_tag: ''               # e.g. icon_tag("testimonial", ["icon-with-text"])
  #     }
  #   },
  #   {
  #     type: :status_info,
  #     content: {
  #       info_text_part: 'msg',
  #       info_icon_part_classes: 'class1 class2'
  #     }
  #   },
  #   {
  #     type: :status_links,
  #     content: [{
  #         link_href: @current_community.payment_gateway.new_payment_path(@current_user, conversation, params[:locale],
  #         link_classes: '[if-any]'
  #         link_data: {},                  # e.g. {:method => "put", :remote => "true"}
  #         link_icon_tag: '[some-tag]>',   # OR link_icon_with_text_classes: icon_for("accepted")
  #         link_text_with_icon: 'Something'
  #       },
  #       {}
  #     ]
  #   }
  # }
  def get_conversation_statuses(conversation)
    conversation_statuses = []
    if conversation.listing && !conversation.status.eql?("free")
      if conversation.status.eql?("pending")
        conversation_statuses << pending_status(conversation)
      elsif conversation.status.eql?("accepted")
        conversation_statuses << status_info(t("conversations.status.#{conversation.discussion_type}_accepted"), icon_classes: icon_for("accepted"))
        conversation_statuses << accepted_status(conversation)
      elsif conversation.status.eql?("paid")
        conversation_statuses << status_info(t("conversations.status.#{conversation.discussion_type}_paid"), icon_classes: icon_for("paid"))
        conversation_statuses << status_info(t("conversations.status.deliver_listing", :listing_title => link_to(conversation.listing.title, conversation.listing)).html_safe, icon_classes: "ss-deliveryvan")
        conversation_statuses << paid_status(conversation, @current_community.testimonials_in_use)
      elsif conversation.status.eql?("preauthorized")
        conversation_statuses << status_info(t("conversations.status.#{conversation.discussion_type}_preauthorized"), icon_classes: icon_for("preauthorized"))
        conversation_statuses << preauthorized_status(conversation)
      elsif conversation.status.eql?("confirmed")
        conversation_statuses << status_info(t("conversations.status.#{conversation.discussion_type}_confirmed"), icon_classes: icon_for("confirmed"))
        conversation_statuses << feedback_status(conversation, @current_community.testimonials_in_use)
      elsif conversation.status.eql?("canceled")
        conversation_statuses << status_info(t("conversations.status.#{conversation.discussion_type}_canceled"), icon_classes: icon_for("canceled"))
        conversation_statuses << feedback_status if @current_community.testimonials_in_use
      elsif conversation.status
        conversation_statuses << status_info(t("conversations.status.#{conversation.discussion_type}_#{conversation.status}"), icon_classes: icon_for(conversation.status))
      end
    end
    conversation_statuses.flatten()
  end

  private

  # OSAPUOLEN PÄÄTTELEMINEN

  def pending_status(conversation)
    if current_user?(conversation.listing.author)
      waiting_for_current_user_to_accept(conversation)
    else
      waiting_for_author_acceptance(conversation)
    end
  end

  def accepted_status(conversation)
    if conversation.listing.offerer?(@current_user)
      waiting_for_buyer_to_pay(conversation)
    else
      waiting_for_current_user_to_pay(conversation)
    end
  end

  def paid_status(conversation, show_testimonial_status)
    return nil if show_testimonial_status

    if conversation.listing.offerer?(@current_user)
      waiting_for_buyer_to_confirm(conversation)
    else
      waiting_for_current_user_to_confirm(conversation)
    end
  end

  def preauthorized_status(conversation)
    if current_user?(conversation.listing.author)
      waiting_for_current_user_to_accept(conversation)
    else
      waiting_for_author_to_accept(conversation)
    end
  end

  def feedback_status(conversation, show_feedback_status)
    return nil unless show_feedback_status

    if conversation.has_feedback_from?(@current_user)
      feedback_given_status
    elsif conversation.feedback_skipped_by?(@current_user)
      feedback_skipped_status
    else
      feedback_pending_status
    end
  end

  ## STATUKSEN TEKEMINEN

  def waiting_for_author_acceptance(conversation)
    other_party = conversation.other_party(@current_user)
    other_party_link = link_to(other_party.given_name_or_username, other_party)

    link = t(
      "conversations.status.waiting_for_listing_author_to_accept_#{conversation.discussion_type}",
      :listing_author_name => other_party_link
    ).html_safe

    status_info(link, icon_classes: 'ss-clock')
  end

  def waiting_for_current_user_to_accept(conversation)
    {
      type: :status_links,
      content: get_status_link(["accept", "reject"], conversation)
    }
  end

  def waiting_for_current_user_to_pay
    {
      type: :status_links,
      content: [
        {
          link_href: @current_community.payment_gateway.new_payment_path(@current_user, conversation, params[:locale]),
          link_classes: 'accept',
          link_icon_with_text_classes: 'ss-coins',
          link_text_with_icon: t("conversations.status.pay")
        },
        {
          link_href: cancel_person_message_path(@current_user, :id => conversation.id.to_s),
          link_classes: 'cancel',
          link_icon_with_text_classes: icon_for("canceled"),
          link_text_with_icon: t("conversations.status.cancel_payed_transaction")
        }
      ]
    }
  end

  def waiting_for_buyer_to_pay
    link = t("conversations.status.waiting_payment_from_requester", :requester_name => link_to(conversation.requester.given_name_or_username, conversation.requester)).html_safe
    status_info(link, icon_classes: 'ss-clock')
  end

  def waiting_for_buyer_to_confirm(conversation)
    link = t("conversations.status.waiting_confirmation_from_requester",
      :requester_name => link_to(
        conversation.other_party(@current_user).given_name_or_username,
        conversation.other_party(@current_user)
      )
    ).html_safe

    status_info(link, icon_classes: 'ss-clock')
  end

  def waiting_for_current_user_to_confirm(conversation)
    {
      type: :status_links,
      content: get_status_link(["confirm", "cancel"], conversation)
    }
  end

    def waiting_for_current_user_to_accept(conversation)
    {
      type: :status_links,
      content: get_status_link(["accept_preauthorized", "reject_preauthorized"], conversation)
    }
  end

  def waiting_for_author_to_accept(conversation)
    text = t("conversations.status.waiting_for_listing_author_to_accept_#{conversation.discussion_type}",
      :listing_author_name => link_to(
        conversation.other_party(@current_user).given_name_or_username,
        conversation.other_party(@current_user)
      )
    ).html_safe

    status_info(text, icon_classes: 'ss-clock')
  end

  def feedback_given_status
    status_info(t("conversations.status.feedback_given"), icon_tag: icon_tag("testimonial", ["icon-part"]))
  end

  def feedback_skipped_status
    status_info(t("conversations.status.feedback_skipped"), icon_classes: "ss-skipforward")
  end

  def feedback_pending_status
    {
      type: :status_links,
      content: [
        {
          link_href: new_person_message_feedback_path(@current_user, :message_id => conversation.id.to_s),
          link_classes: '',
          link_icon_with_tag: icon_tag("testimonial", ["icon-with-text"]),
          link_text_with_icon: t("conversations.status.give_feedback")
        },
        {
          link_href: skip_person_message_feedbacks_path(@current_user, :message_id => conversation.id.to_s),
          link_classes: 'cancel',
          link_data: { :method => "put", :remote => "true"},
          link_icon_with_text_classes: "ss-skipforward",
          link_text_with_icon: t("conversations.status.skip_feedback")
        }
      ]
    }
  end

  ## LOW LEVEL STATUS FACTORYT

  def status_info(text, icon_tag: nil, icon_classes: nil)
    hash = {
      type: :status_info,
      content: {
        info_text_part: text
      }
    }

    if icon_tag
      hash.deep_merge(content: {info_icon_tag: icon_tag})
    elsif icon_classes
      hash.deep_merge(content: {info_icon_part_classes: icon_classes})
    else
      hash
    end
  end

  def get_status_link(status_link_names, conversation)
    status_link_names.map do |status_link_name|
      {
        link_href: path_for_status_link("#{status_link_name}", conversation, @current_user),
        link_classes: "#{status_link_name}",
        link_icon_with_text_classes: icon_for("#{status_link_name}ed"),
        link_text_with_icon:
          if ["accept", "reject"].include?(status_link_name)
            t("conversations.status_link.#{status_link_name}_#{conversation.discussion_type}")
          elsif ["accept_preauthorized", "reject_preauthorized"].include?(status_link_name)
            t("conversations.status_link.#{status_link_name}_#{conversation.discussion_type}")
          else
            t("conversations.status_link.#{status_link_name}")
          end
      }
    end
  end
end

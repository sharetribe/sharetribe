module ListingConversationsHelper
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
    when "accept_preauthorized"
      "ss-check"
    when "reject_preauthorized"
      "ss-delete"
    end
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
    statuses = if conversation.listing && !conversation.status.eql?("free")
      case conversation.status
      when "pending"
        [
          pending_status(conversation)
        ]
      when "accepted"
        [
          status_info(t("conversations.status.#{conversation.discussion_type}_accepted"), icon_classes: icon_for("accepted")),
          accepted_status(conversation)
        ]
      when "paid"
        [
          status_info(t("conversations.status.#{conversation.discussion_type}_paid"), icon_classes: icon_for("paid")),
          status_info(t("conversations.status.deliver_listing", :listing_title => link_to(conversation.listing.title, conversation.listing)).html_safe, icon_classes: "ss-deliveryvan"),
          paid_status(conversation, @current_community.testimonials_in_use)
        ]
      when "preauthorized"
        [
          status_info(t("conversations.status.#{conversation.discussion_type}_preauthorized"), icon_classes: icon_for("preauthorized")),
          preauthorized_status(conversation)
        ]
      when "confirmed"
        [
          status_info(t("conversations.status.#{conversation.discussion_type}_confirmed"), icon_classes: icon_for("confirmed")),
          feedback_status(conversation, @current_community.testimonials_in_use)
        ]
      when "canceled"
        [
          status_info(t("conversations.status.#{conversation.discussion_type}_canceled"), icon_classes: icon_for("canceled")),
          feedback_status(conversation, @current_community.testimonials_in_use)
        ]
      else
        [
          status_info(t("conversations.status.#{conversation.discussion_type}_#{conversation.status}"), icon_classes: icon_for(conversation.status))
        ]
      end
    else
      []
    end

    statuses.flatten.compact
  end

  private

  def pending_status(conversation)
    if current_user?(conversation.listing.author)
      StatusLinkBuilder.new(conversation).waiting_for_current_user_to_accept
    else
      StatusInfoBuilder.new(conversation).waiting_for_author_acceptance
    end
  end

  def accepted_status(conversation)
    if conversation.listing.offerer?(@current_user)
      StatusInfoBuilder.new(conversation).waiting_for_buyer_to_pay
    else
      StatusLinkBuilder.new(conversation).waiting_for_current_user_to_pay
    end
  end

  def paid_status(conversation, show_testimonial_status)
    return nil if show_testimonial_status

    if conversation.listing.offerer?(@current_user)
      StatusInfoBuilder.new(conversation).waiting_for_buyer_to_confirm
    else
      StatusLinkBuilder.new(conversation).waiting_for_current_user_to_confirm
    end
  end

  def preauthorized_status(conversation)
    binding.pry
    if current_user?(conversation.listing.author)
      StatusLinkBuilder.new(conversation).waiting_for_current_user_to_accept_preauthorized(conversation)
    else
      StatusInfoBuilder.new(conversation).waiting_for_author_to_accept_preauthorized(conversation)
    end
  end

  def feedback_status(conversation, show_feedback_status)
    return nil unless show_feedback_status

    if conversation.has_feedback_from?(@current_user)
      StatusInfoBuilder.new(conversation).feedback_given_status
    elsif conversation.feedback_skipped_by?(@current_user)
      StatusInfoBuilder.new(conversation).feedback_skipped_status
    else
      StatusLinkBuilder.new(conversation).feedback_pending_status
    end
  end

  class StatusLinkBuilder
    attr_reader :conversation

    def initialize(conversation)
      @conversation = conversation
    end

    def waiting_for_current_user_to_accept
      status_links([
        {
          link_href: accept_person_message_path(@current_user, :id => conversation.id),
          link_classes: "accept",
          link_icon_with_text_classes: icon_for("accepted"),
          link_text_with_icon: link_text_with_icon(conversation, "accept")
        },
        {
          link_href: reject_person_message_path(@current_user, :id => conversation.id),
          link_classes: "reject",
          icon_classes: icon_for("rejected"),
          link_text_with_icon: link_text_with_icon(conversation, "reject")
        }
      ])
    end

    def waiting_for_current_user_to_pay
      status_links([
        {
          link_href: @current_community.payment_gateway.new_payment_path(@current_user, conversation, params[:locale]),
          link_classes: "accept",
          link_icon_with_text_classes: 'ss-coins',
          link_text_with_icon: t("conversations.status.pay")
        },
        {
          link_href: cancel_person_message_path(@current_user, :id => conversation.id),
          link_classes: 'cancel',
          link_icon_with_text_classes: icon_for("canceled"),
          link_text_with_icon: t("conversations.status.cancel_payed_transaction")
        }
      ])
    end

    def waiting_for_current_user_to_confirm
      status_links([
        {
          link_href: confirm_person_message_path(@current_user, :id => conversation.id),
          link_classes: "confirm",
          link_icon_with_text_classes: icon_for("confirmed"),
          link_text_with_icon: link_text_with_icon(conversation, "confirm")
        },
        {
          link_href: cancel_person_message_path(@current_user, :id => conversation.id),
          link_classes: "cancel",
          link_icon_with_text_classes: icon_for("canceled"),
          link_text_with_icon: link_text_with_icon(conversation, "cancel")
        }
      ])
    end

    def waiting_for_current_user_to_accept_preauthorized
      status_links([
        {
          link_href: accept_preauthorized_person_message_path(@current_user, :id => conversation.id),
          link_classes: "accept_preauthorized",
          link_icon_with_text_classes: icon_for("accept_preauthorized"),
          link_text_with_icon: link_text_with_icon(conversation, "accept_preauthorized")
        },
        {
          link_href: reject_preauthorized_person_message_path(@current_user, :id => conversation.id),
          link_classes: "reject_preauthorized",
          link_icon_with_text_classes: icon_for("reject_preauthorized"),
          link_text_with_icon: link_text_with_icon(conversation, "reject_preauthorized")
        }
      ]);
    end

    def feedback_pending_status
      status_links([
        {
          link_href: new_person_message_feedback_path(@current_user, :message_id => conversation.id),
          link_icon_with_tag: icon_tag("testimonial", ["icon-with-text"]),
          link_text_with_icon: t("conversations.status.give_feedback")
        },
        {
          link_href: skip_person_message_feedbacks_path(@current_user, :message_id => conversation.id),
          link_classes: "cancel",
          link_icon_with_text_classes: "ss-skipforward",
          link_text_with_icon: t("conversations.status.skip_feedback"),
          link_data: { :method => "put", :remote => "true"}
        }
      ])
    end

    private

    def status_links(content)
      {
        type: :status_links,
        content: content
      }
    end

    def link_text_with_icon(conversation, status_link_name)
      if ["accept", "reject", "accept_preauthorized", "reject_preauthorized"].include?(status_link_name)
        t("conversations.status_link.#{status_link_name}_#{conversation.discussion_type}")
      else
        t("conversations.status_link.#{status_link_name}")
      end
    end
  end

  class StatusInfoBuilder
    attr_reader :conversation

    def initialize(conversation)
      @conversation = conversation
    end

    def waiting_for_author_acceptance(conversation)
      other_party = conversation.other_party(@current_user)
      other_party_link = link_to(other_party.given_name_or_username, other_party)

      link = t(
        "conversations.status.waiting_for_listing_author_to_accept_#{conversation.discussion_type}",
        :listing_author_name => other_party_link
      ).html_safe

      status_info(link, icon_classes: 'ss-clock')
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

    def waiting_for_author_to_accept_preauthorized(conversation)
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

    private

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
  end
end
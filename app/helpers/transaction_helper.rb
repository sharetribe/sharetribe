module TransactionHelper

  def icon_for(status)
    case status
    when "confirmed"
      "ss-check"
    when "rejected"
      "ss-delete"
    when "canceled"
      "ss-delete"
    when "accepted"
      "ss-check"
    when "paid"
      "ss-check"
    when "preauthorized"
      "ss-check"
    when "pending_ext"
      "ss-alert"
    when "accept_preauthorized"
      "ss-check"
    when "reject_preauthorized"
      "ss-delete"
    when "errored"
      "ss-delete"
    end
  end

  # Give `status`, `is_author` and `other_party` and get back icon and text for current status
  # rubocop:disable all
  def conversation_icon_and_status(status, is_author, other_party_name, waiting_feedback, status_meta)
    icon_waiting_you = icon_tag("alert", ["icon-fix-rel", "waiting-you"])
    icon_waiting_other = icon_tag("clock", ["icon-fix-rel", "waiting-other"])

    # Split "confirmed" status into "waiting_feedback" and "completed"
    status = if waiting_feedback
      "waiting_feedback"
    else
      "completed"
    end if status == "confirmed"

    status_hash = {
      pending: ->() {
        ActiveSupport::Deprecation.warn("Transaction state 'pending' is deprecated and will be removed in the future.")
        {
          author: {
            icon: icon_waiting_you,
            text: t("conversations.status.waiting_for_you_to_accept_request")
          },
          starter: {
            icon: icon_waiting_other,
            text: t("conversations.status.waiting_for_listing_author_to_accept_request", listing_author_name: other_party_name)
          }
        } },
      preauthorized: ->() { {
        author: {
          icon: icon_waiting_you,
          text: t("conversations.status.waiting_for_you_to_accept_request")
        },
        starter: {
          icon: icon_waiting_other,
          text: t("conversations.status.waiting_for_listing_author_to_accept_request", listing_author_name: other_party_name)
        }
      } },
      accepted: ->() {
        ActiveSupport::Deprecation.warn("Transaction state 'accepted' is deprecated and will be removed in the future.")
          {
          author: {
            icon: icon_waiting_other,
            text: t("conversations.status.waiting_payment_from_requester", requester_name: other_party_name)
          },
          starter: {
            icon: icon_waiting_you,
            text: t("conversations.status.waiting_payment_from_you")
          }
        } },
      pending_ext: ->() {
        case status_meta[:paypal_pending_reason]
        when "multicurrency"
          {
            author: {
              icon: icon_waiting_you,
              # Make this aware of the reason
              text: t("conversations.status.pending_external_inbox.paypal.multicurrency")
            },
            starter: {
              icon: icon_waiting_other,
              text: t("conversations.status.waiting_for_listing_author_to_accept_request", listing_author_name: other_party_name)
            }
          }
        when "intl"
          {
            author: {
              icon: icon_waiting_you,
              # Make this aware of the reason
              text: t("conversations.status.pending_external_inbox.paypal.intl")
            },
            starter: {
              icon: icon_waiting_other,
              text: t("conversations.status.waiting_for_listing_author_to_accept_request", listing_author_name: other_party_name)
            }
          }
        when "verify"
          {
            author: {
              icon: icon_waiting_you,
              # Make this aware of the reason
              text: t("conversations.status.pending_external_inbox.paypal.verify")
            },
            starter: {
              icon: icon_waiting_other,
              text: t("conversations.status.waiting_for_listing_author_to_accept_request", listing_author_name: other_party_name)
            }
          }
        else # some pending_ext reason we don't have special message for
          {
            author: {
              icon: icon_waiting_you,
              text: t("conversations.status.pending_external_inbox.paypal.unknown_reason")
            },
            starter: {
              icon: icon_waiting_other,
              text: t("conversations.status.waiting_for_listing_author_to_accept_request", listing_author_name: other_party_name)
            }
          }
        end
      },

      rejected: -> () { {
        both: {
          icon: icon_tag("cross", ["icon-fix-rel", "rejected"]),
          text: t("conversations.status.request_rejected")
        }
      } },

      paid: ->() { {
        author: {
          icon: icon_waiting_other,
          text: t("conversations.status.waiting_confirmation_from_requester", requester_name: other_party_name)
        },
        starter: {
          icon: icon_waiting_you,
          text: t("conversations.status.waiting_confirmation_from_you")
        }
      } },

      waiting_feedback: ->() { {
        both: {
          icon: icon_waiting_you,
          text: t("conversations.status.waiting_feedback_from_you")
        }
      } },

      completed: ->() { {
        both: {
          icon: icon_tag("check", ["icon-fix-rel", "confirmed"]),
          text: t("conversations.status.request_confirmed")
        }
      } },

      canceled: ->() { {
        both: {
          icon: icon_tag("cross", ["icon-fix-rel", "canceled"]),
          text: t("conversations.status.request_canceled")
        }
      } },

      errored: ->() { {
        both: {
          icon: icon_tag("cross", ["icon-fix-rel", "canceled"]),
          text: t("conversations.status.payment_errored")
         }
      } },
    }

    Maybe(status_hash)[status.to_sym]
      .map { |s| s.call }
      .map { |s| Maybe(is_author ? s[:author] : s[:starter]).or_else { s[:both] } }
      .values
      .get
  end
  # rubocop:enable all

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
  #         link_href: "/path/to/somewhere" # url
  #         link_classes: '[if-any]'
  #         link_data: {},                  # e.g. {:method => "put", :remote => "true"}
  #         link_icon_tag: '[some-tag]>',   # OR link_icon_with_text_classes: icon_for("accepted")
  #         link_text_with_icon: 'Something'
  #       },
  #       {}
  #     ]
  #   }
  # }
  def get_conversation_statuses(conversation, is_author)
    statuses = if conversation.listing && !conversation.status.eql?("free")
      status_hash = {
        paid: ->() { {
          both: [
            status_info(t("conversations.status.request_paid"), icon_classes: icon_for("paid")),
            delivery_status(conversation),
            paid_status(conversation)
          ]
        } },
        preauthorized: ->() { {
          both: [
            status_info(t("conversations.status.request_preauthorized"), icon_classes: icon_for("preauthorized")),
            preauthorized_status(conversation)
          ]
        } },
        pending_ext: ->() {
          ## This is so wrong place to call services...
          #TODO Deprecated call, update to use PaypalService::API:Api.payments.get_payment
          paypal_payment = PaypalService::Store::PaypalPayment.for_transaction(conversation.id)

          reason = Maybe(conversation).transaction_transitions.last.metadata["paypal_pending_reason"]

          case reason
          when Some("multicurrency")
            {
              author: [
                status_info(t("conversations.status.pending_external.paypal.multicurrency", currency: paypal_payment[:payment_total].currency, paypal_url: link_to("https://www.paypal.com", "https://www.paypal.com")).html_safe, icon_classes: icon_for("pending_ext"))
              ],
              starter: [
                status_info(t("conversations.status.request_preauthorized"), icon_classes: icon_for("preauthorized")),
                preauthorized_status(conversation)
              ]
            }
          when Some("intl")
            {
              author: [
                status_info(t("conversations.status.pending_external.paypal.intl", paypal_url: link_to("https://www.paypal.com", "https://www.paypal.com")).html_safe, icon_classes: icon_for("pending_ext"))
              ],
              starter: [
                status_info(t("conversations.status.request_preauthorized"), icon_classes: icon_for("preauthorized")),
                preauthorized_status(conversation)
              ]
            }
          when Some("verify")
            {
              author: [
                status_info(t("conversations.status.pending_external.paypal.verify", paypal_url: link_to("https://www.paypal.com", "https://www.paypal.com")).html_safe, icon_classes: icon_for("pending_ext"))
              ],
              starter: [
                status_info(t("conversations.status.request_preauthorized"), icon_classes: icon_for("preauthorized")),
                preauthorized_status(conversation)
              ]
            }
          end
        },
        confirmed: ->() { {
          both: [
            status_info(t("conversations.status.request_confirmed"), icon_classes: icon_for("confirmed")),
            feedback_status(conversation)
          ]
        } },
        canceled: ->() { {
          both: [
            status_info(t("conversations.status.request_canceled"), icon_classes: icon_for("canceled")),
            feedback_status(conversation)
          ]
        } },
        rejected: ->() { {
          both: [
            status_info(t("conversations.status.request_rejected"), icon_classes: icon_for(conversation.status))
          ]
        } },
        errored: ->() { {
          author: [
            status_info(t("conversations.status.payment_errored_author", starter_name: conversation.starter.name(conversation.community)), icon_classes: icon_for("errored"))
          ],
          starter: [
            status_info(t("conversations.status.payment_errored_starter"), icon_classes: icon_for("errored"))
          ]
        } }
      }

      Maybe(status_hash)[conversation.status.to_sym]
        .map { |s| s.call }
        .map { |s| Maybe(is_author ? s[:author] : s[:starter]).or_else { s[:both] } }
        .or_else([])
    else
      []
    end

    statuses.flatten.compact
  end

  private

  def paid_status(conversation)
    if conversation.seller == @current_user
      waiting_for_buyer_to_confirm(conversation)
    else
      waiting_for_current_user_to_confirm(conversation)
    end
  end

  def delivery_status(conversation)
    if current_user?(conversation.author)
      status_info(
        t("conversations.status.waiting_for_current_user_to_deliver_listing",
          :listing_title => link_to(conversation.listing.title, conversation.listing)
        ).html_safe,
        icon_classes: "ss-clockwise"
      )
    else
      status_info(
        t("conversations.status.waiting_for_listing_author_to_deliver_listing",
          :listing_title => link_to(conversation.listing.title, conversation.listing),
          :listing_author_name => link_to(PersonViewUtils.person_display_name(conversation.author, conversation.community))
        ).html_safe,
        icon_classes: "ss-clockwise"
      )
    end
  end

  def preauthorized_status(transaction)
    if current_user?(transaction.listing.author)
      waiting_for_current_user_to_accept_preauthorized(transaction)
    else
      waiting_for_author_to_accept_preauthorized(transaction)
    end
  end

  def feedback_status(conversation)
    if conversation.has_feedback_from?(@current_user)
      feedback_given_status
    elsif conversation.feedback_skipped_by?(@current_user)
      feedback_skipped_status
    else
      feedback_pending_status(conversation)
    end
  end

  def waiting_for_current_user_to_confirm(conversation)
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

  def waiting_for_current_user_to_accept_preauthorized(transaction)
    status_links([
      {
        link_href: accept_preauthorized_person_message_path(@current_user, :id => transaction.id),
        link_classes: "accept_preauthorized",
        link_icon_with_text_classes: icon_for("accept_preauthorized"),
        link_text_with_icon: link_text_with_icon(transaction, "accept_preauthorized")
      },
      {
        link_href: reject_preauthorized_person_message_path(@current_user, :id => transaction.id),
        link_classes: "reject_preauthorized",
        link_icon_with_text_classes: icon_for("reject_preauthorized"),
        link_text_with_icon: link_text_with_icon(transaction, "reject_preauthorized")
      }
    ]);
  end

  def feedback_pending_status(conversation)
    status_links([
      {
        link_href: new_person_message_feedback_path(@current_user, :message_id => conversation.id),
        link_classes: "accept",
        link_icon_tag: icon_tag("testimonial", ["icon-with-text"]),
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

  def status_links(content)
    {
      type: :status_links,
      content: content
    }
  end

  def link_text_with_icon(conversation, status_link_name)
    if ["accept", "reject", "accept_preauthorized", "reject_preauthorized"].include?(status_link_name)
      t("conversations.status_link.#{status_link_name}_request")
    else
      t("conversations.status_link.#{status_link_name}")
    end
  end

  def waiting_for_buyer_to_confirm(conversation)
    key = conversation.payment_gateway == :stripe ? "conversations.status.stripe.waiting_confirmation_from_requester" : "conversations.status.waiting_confirmation_from_requester"
    link = t(key,
      :requester_name => link_to(
        PersonViewUtils.person_display_name_for_type(conversation.other_party(@current_user), "first_name_only"),
        conversation.other_party(@current_user)
      )
    ).html_safe

    status_info(link, icon_classes: 'ss-clock')
  end

  def waiting_for_author_to_accept_preauthorized(transaction)
    text = t("conversations.status.waiting_for_listing_author_to_accept_request",
      :listing_author_name => link_to(
        PersonViewUtils.person_display_name_for_type(transaction.author, "first_name_only"),
        transaction.author
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

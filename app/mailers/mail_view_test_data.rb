# Define helper methods to create test data
# for mail view
module MailViewTestData
  def admin_email
    @admin_email ||= FactoryBot.build(:email, address: "admin@marketplace.com")
  end

  def admin
    @admin ||= FactoryBot.build(:person, emails: [admin_email])
  end

  def author
    @author ||= FactoryBot.build(:person)
  end

  def starter
    @starter ||= FactoryBot.build(:person)
  end

  def member
    return @member unless @member.nil?

    @member ||= FactoryBot.build(:person)
    @member.emails.first.confirmation_token = "123456abcdef"
    @member
  end

  def community_memberships
    @community_memberships ||= [
      FactoryBot.build(:community_membership, person: admin, admin: true),
      FactoryBot.build(:community_membership, person: author),
      FactoryBot.build(:community_membership, person: starter),
      FactoryBot.build(:community_membership, person: member)
    ]
  end

  def members
    @members ||= [admin, author, starter, member]
  end

  def listing
    @listing ||= FactoryBot.build(:listing,
      author: author,
      id: 123
    )
  end

  def participations
    @participations ||= [
      FactoryBot.build(:participation, person: author),
      FactoryBot.build(:participation, person: starter, is_starter: true)
    ]
  end

  def transaction
    @transaction ||= FactoryBot.build(:transaction,
      id: 99,
      community: community,
      listing: listing,
      payment: payment,
      conversation: conversation,
      automatic_confirmation_after_days: 5
    )
  end

  def paypal_transaction
    @paypal_transaction ||= FactoryBot.build(:transaction,
      id: 100,
      community: paypal_community,
      listing: listing,
      conversation: conversation,
      payment_gateway: :paypal,
      current_state: :paid,
      shipping_price_cents: 100
      )
  end

  def paypal_community
    @paypal_community ||= FactoryBot.build(:community,
      custom_color1: "00FF99",
      id: 999
      )
  end

  def conversation
    @conversation ||= FactoryBot.build(:conversation,
      id: 99,
      community: community,
      listing: listing,
      participations: participations,
      participants: [author, starter],
      messages: [message]
    )
  end

  def message
    @message ||= FactoryBot.build(:message,
      sender: starter,
      id: 123
    )
  end

  def community
    @community ||= FactoryBot.build(:community,
      custom_color1: "FF0099",
      admins: [admin],
      members: members,
      community_memberships: community_memberships
    )
  end
end

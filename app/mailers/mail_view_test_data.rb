# Define helper methods to create test data
# for mail view
module MailViewTestData
  def admin_email
    @admin_email ||= FactoryGirl.build(:email, address: "admin@marketplace.com")
  end

  def admin
    @admin ||= FactoryGirl.build(:person, emails: [admin_email])
  end

  def author
    @author ||= FactoryGirl.build(:person)
  end

  def starter
    @starter ||= FactoryGirl.build(:person)
  end

  def member
    return @member unless @member.nil?
    @member ||= FactoryGirl.build(:person)
    @member.emails.first.confirmation_token = "123456abcdef"
    @member
  end

  def community_memberships
    @community_memberships ||= [
      FactoryGirl.build(:community_membership, person: admin, admin: true),
      FactoryGirl.build(:community_membership, person: author),
      FactoryGirl.build(:community_membership, person: starter),
      FactoryGirl.build(:community_membership, person: member)
    ]
  end

  def members
    @members ||= [admin, author, starter, member]
  end

  def listing
    @listing ||= FactoryGirl.build(:listing,
      author: author,
      id: 123
    )
  end

  def participations
    @participations ||= [
      FactoryGirl.build(:participation, person: author),
      FactoryGirl.build(:participation, person: starter, is_starter: true)
    ]
  end

  def transaction
    @transaction ||= FactoryGirl.build(:transaction,
      id: 99,
      community: community,
      listing: listing,
      payment: payment,
      conversation: conversation,
      automatic_confirmation_after_days: 5
    )
  end

  def paypal_transaction
    @paypal_transaction ||= FactoryGirl.build(:transaction,
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
    @paypal_community ||= FactoryGirl.build(:community,
      custom_color1: "00FF99",
      id: 999
      )
  end

  def conversation
    @conversation ||= FactoryGirl.build(:conversation,
      id: 99,
      community: community,
      listing: listing,
      participations: participations,
      participants: [author, starter],
      messages: [message]
    )
  end

  def message
    @message ||= FactoryGirl.build(:message,
      sender: starter,
      id: 123
    )
  end

  def community
    @community ||= FactoryGirl.build(:community,
      custom_color1: "FF0099",
      admins: [admin],
      members: members,
      community_memberships: community_memberships
    )
  end
end

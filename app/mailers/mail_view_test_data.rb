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
    @member ||= FactoryGirl.build(:person)
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

  def payment_gateway
    @braintree_payment_gateway ||= FactoryGirl.build(:braintree_payment_gateway)
  end

  def checkout_payment_gateway
    @checkout_payment_gateway ||= FactoryGirl.build(:checkout_payment_gateway)
  end

  def payment
    return @payment unless @payment.nil?
    @payment ||= FactoryGirl.build(:braintree_payment,
      id: 55,
      payment_gateway:
      payment_gateway,
      payer: starter,
      recipient: author
    )

    # Avoid infinite loop, set conversation here
    @payment.conversation = conversation
    @payment
  end

  def checkout_payment
    return @checkout_payment unless @checkout_payment.nil?
    @checkout_payment ||= FactoryGirl.build(:checkout_payment,
      id: 55,
      payment_gateway: checkout_payment_gateway,
      payer: starter,
      recipient: author
    )

    # Avoid infinite loop, set conversation here
    @checkout_payment.conversation = conversation
    @checkout_payment
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

  def conversation
    @conversation ||= FactoryGirl.build(:listing_conversation,
      id: 99,
      community: community,
      listing: listing,
      payment: payment,
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
      payment_gateway: payment_gateway,
      custom_color1: "FF0099",
      admins: [admin],
      members: members,
      community_memberships: community_memberships
    )
  end

  def checkout_community
    @checkout_community ||= FactoryGirl.build(:community,
      payment_gateway: checkout_payment_gateway,
      custom_color1: "FF0099",
      admins: [admin],
      members: members,
      community_memberships: community_memberships
    )
  end
end
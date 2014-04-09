def email(h)
  defaults = {confirmed_at: Time.now, send_notifications: true}
  HashClass.new(defaults.merge(h))
end

describe EmailService do
  describe "#emails_to_send_message" do

    it "returns all confirmed notification emails" do
      e1 = email(id: 1, send_notifications: false, confirmed_at: Time.now)
      e2 = email(id: 2, send_notifications: true, confirmed_at: Time.now)
      e3 = email(id: 3, send_notifications: true, confirmed_at: Time.now)
      e4 = email(id: 4, send_notifications: true, confirmed_at: nil)

      EmailService.emails_to_send_message([e1, e2, e3, e4]).should eql([e2, e3])
    end

    it "returns first confirmed email if no confirmed notification email is found" do
      e1 = email(id: 1, send_notifications: false, confirmed_at: Time.now)
      e2 = email(id: 2, send_notifications: false, confirmed_at: Time.now)
      e3 = email(id: 3, send_notifications: false, confirmed_at: Time.now)
      e4 = email(id: 4, send_notifications: true, confirmed_at: nil)

      EmailService.emails_to_send_message([e1, e2, e3, e4]).should eql([e1])
    end

    it "otherwise returns an empty array" do
      # This should never happen in production.
      # We should always have at least one confirmed email
      e1 = email(id: 1, send_notifications: false, confirmed_at: nil)
      e2 = email(id: 2, send_notifications: true, confirmed_at: nil)
      e3 = email(id: 3, send_notifications: true, confirmed_at: nil)
      e4 = email(id: 4, send_notifications: true, confirmed_at: nil)

      EmailService.emails_to_send_message([e1, e2, e3, e4]).should eql([])
    end

  end

  describe "#emails_to_smtp_addresses" do

    it "returns comma-separated list of emails" do
      EmailService.emails_to_smtp_addresses([
        email(address: "john.doe@example.com"),
        email(address: "john_d@example.com"),
        email(address: "jdoe@example.com")
      ]).should eql "john.doe@example.com, john_d@example.com, jdoe@example.com"
    end

    it "returns only one email (without commas, of course)" do
      EmailService.emails_to_smtp_addresses([
        email(address: "john.doe@example.com"),
      ]).should eql "john.doe@example.com"
    end

    it "returns empty string" do
      EmailService.emails_to_smtp_addresses([]).should eql ""
    end

  end

  describe "#can_delete_email" do
    it "can not delete email if email count == 1" do
      EmailService.can_delete_email(
        [email(id: 1)],
        email(id: 1),
      ).should eql({result: false, reason: :only_one})

      EmailService.can_delete_email(
        [email(id: 1), email(id: 2)],
        email(id: 1),
      ).should eql({result: true})
    end

    it "can not delete email if that's the only CONFIRMED email" do
      EmailService.can_delete_email(
        [email(id: 1, confirmed_at: Time.now), email(id: 2, confirmed_at: nil)],
        email(id: 1),
      ).should eql({result: false, reason: :only_confirmed})

      EmailService.can_delete_email(
        [email(id: 1, confirmed_at: Time.now), email(id: 2, confirmed_at: Time.now)],
        email(id: 1),
      ).should eql({result: true})
    end

    it "can not delete email if that's the only notification email" do
      EmailService.can_delete_email(
        [email(id: 1, send_notifications: true), email(id: 2, send_notifications: false)],
        email(id: 1),
      ).should eql({result: false, reason: :only_notification})

      EmailService.can_delete_email(
        [email(id: 1, send_notifications: true), email(id: 2, send_notifications: true)],
        email(id: 1),
      ).should eql({result: true})
    end

    it "can not delete email if that's the only CONFIRMED notification email" do
      EmailService.can_delete_email(
        [
          email(id: 1, send_notifications: true, confirmed_at: Time.now),
          email(id: 2, send_notifications: false, confirmed_at: Time.now),
          email(id: 3, send_notifications: true, confirmed_at: nil)
        ],
        email(id: 1),
      ).should eql({result: false, reason: :only_notification})

      EmailService.can_delete_email(
        [
          email(id: 1, send_notifications: true, confirmed_at: Time.now),
          email(id: 2, send_notifications: false, confirmed_at: Time.now),
          email(id: 3, send_notifications: true, confirmed_at: Time.now)
        ],
        email(id: 1),
      ).should eql({result: true})
    end

    it "can not delete email if that's the only email required by community" do
      EmailService.can_delete_email(
        [email(id: 1, address: "john@community.com"), email(id: 2, address: "john@gmail.com")],
        email(id: 1),
        ["community.com"],
      ).should eql({result: false, reason: :only_allowed})

      EmailService.can_delete_email(
        [email(id: 1, address: "john@community.com"), email(id: 2, address: "john@gmail.com")],
        email(id: 2),
        ["community.com"],
      ).should eql({result: true})

      # Two allowed emails for one community
      EmailService.can_delete_email(
        [
          email(id: 1, address: "john@community.com"),
          email(id: 2, address: "john@gmail.com"),
          email(id: 3, address: "john@my.community.com")
        ],
        email(id: 1),
        ["community.com"],
      ).should eql({result: true})

      # One allowed emails for two communities
      EmailService.can_delete_email(
        [
          email(id: 1, address: "john@community.com"),
          email(id: 2, address: "john@gmail.com"),
          email(id: 3, address: "john@organization.com")
        ],
        email(id: 3),
        ["community.com", "organization.com"],
      ).should eql({result: false, reason: :only_allowed})

      EmailService.can_delete_email(
        [
          email(id: 1, address: "john@community.com"),
          email(id: 2, address: "john@gmail.com"),
          email(id: 3, address: "john@organization.com"),
          email(id: 3, address: "john@my.organization.com")
        ],
        email(id: 3),
        ["community.com", "organization.com"],
      ).should eql({result: true})
    end

    it "can not delete email if that's the only CONFIRMED email required by community" do
      # Two allowed emails for one community
      EmailService.can_delete_email(
        [
          email(id: 1, address: "john@community.com", confirmed_at: nil),
          email(id: 2, address: "john@gmail.com"),
          email(id: 3, address: "john@my.community.com")
        ],
        email(id: 1),
        ["community.com"],
      ).should eql({result: false, reason: :only_allowed})

            # Two allowed emails for one community
      EmailService.can_delete_email(
        [
          email(id: 1, address: "john@community.com", confirmed_at: Time.now),
          email(id: 2, address: "john@gmail.com"),
          email(id: 3, address: "john@my.community.com", confirmed_at: Time.now)
        ],
        email(id: 1),
        ["community.com"],
      ).should eql({result: true})
    end
  end
end

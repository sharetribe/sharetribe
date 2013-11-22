# This should go to a helper
# http://pullmonkey.com/2008/01/06/convert-a-ruby-hash-into-a-class-object/
class HashClass
  def initialize(hash)
    hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
    end
  end
end

def email(h)
  defaults = {confirmed_at: Time.now, send_notifications: true}
  HashClass.new(defaults.merge(h))
end

describe EmailService do
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
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

def hashit(h)
  HashClass.new(h)
end

describe EmailService do
  describe "#can_delete_email" do
    it "can not delete email if email count == 1" do
      EmailService.can_delete_email(
        [hashit(id: 1, send_notifications: true)],
        [],
        hashit(id: 1),
      ).should eql({result: false, reason: :only_one})

      EmailService.can_delete_email(
        [hashit(id: 1, send_notifications: true), hashit(id: 2, send_notifications: true)],
        [],
        hashit(id: 1),
      ).should eql({result: true})
    end

    it "can not delete email if that's the only notification email" do
      EmailService.can_delete_email(
        [hashit(id: 1, send_notifications: true), hashit(id: 2, send_notifications: false)],
        [],
        hashit(id: 1),
      ).should eql({result: false, reason: :only_notification})

      EmailService.can_delete_email(
        [hashit(id: 1, send_notifications: true), hashit(id: 2, send_notifications: true)],
        [],
        hashit(id: 1),
      ).should eql({result: true})
    end

    it "can not delete email if that's the only email required by community" do
      EmailService.can_delete_email(
        [hashit(id: 1, send_notifications: true, address: "john@community.com"), hashit(id: 2, send_notifications: true, address: "john@gmail.com")],
        ["community.com"],
        hashit(id: 1),
      ).should eql({result: false, reason: :only_allowed})

      EmailService.can_delete_email(
        [hashit(id: 1, send_notifications: true, address: "john@community.com"), hashit(id: 2, send_notifications: true, address: "john@gmail.com")],
        ["community.com"],
        hashit(id: 2),
      ).should eql({result: true})

      # Two allowed emails for one community
      EmailService.can_delete_email(
        [
          hashit(id: 1, send_notifications: true, address: "john@community.com"),
          hashit(id: 2, send_notifications: true, address: "john@gmail.com"),
          hashit(id: 3, send_notifications: true, address: "john@my.community.com")
        ],
        ["community.com"],
        hashit(id: 1),
      ).should eql({result: true})

      # One allowed emails for two communities
      EmailService.can_delete_email(
        [
          hashit(id: 1, send_notifications: true, address: "john@community.com"),
          hashit(id: 2, send_notifications: true, address: "john@gmail.com"),
          hashit(id: 3, send_notifications: true, address: "john@organization.com")
        ],
        ["community.com", "organization.com"],
        hashit(id: 3),
      ).should eql({result: false, reason: :only_allowed})

      EmailService.can_delete_email(
        [
          hashit(id: 1, send_notifications: true, address: "john@community.com"),
          hashit(id: 2, send_notifications: true, address: "john@gmail.com"),
          hashit(id: 3, send_notifications: true, address: "john@organization.com"),
          hashit(id: 3, send_notifications: true, address: "john@my.organization.com")
        ],
        ["community.com", "organization.com"],
        hashit(id: 3),
      ).should eql({result: true})
    end
  end
end
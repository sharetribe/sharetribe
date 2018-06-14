module DeletePerson
  extend ActiveSupport::Concern

  included do
    class << self
      def delete_user(id)
        person = Person.find_by(id: id)

        if person.nil?
          return false
        else
          # Delete personal information
          person.update_attributes(
            given_name: nil,
            family_name: nil,
            display_name: nil,
            phone_number: nil,
            description: nil,
            email: nil,
            facebook_id: nil,
            username: "deleted_#{SecureRandom.hex(5)}",
            current_sign_in_ip: nil,
            last_sign_in_ip: nil,
            # To ensure user can not log in anymore we have to:
            #
            # 1. Delete the password (Devise rejects login attempts if the password is empty)
            # 2. Remove the emails (So that use can not reset the password)
            encrypted_password: "",
            deleted: true # Flag deleted
          )

          # Delete emails
          person.emails.destroy_all

          # Delete location
          person.location&.destroy

          # Delete avatar
          person.image.destroy
          person.image.clear
          person.image = nil
          person.save(validate: false)

          # Delete follower relations, both way
          person.follower_relationships.destroy_all
          person.inverse_follower_relationships.destroy_all

          # Delete memberships
          person.community_membership.update_attributes(status: "deleted_user")

          # Delte auth tokens
          person.auth_tokens.destroy_all

          person.custom_field_values.destroy_all
        end
      end
    end
  end
end

require 'openssl'
require 'base64'

module PeopleHelper

  def persons_listings(person, per_page=6, page=1)
    if current_user?(person) && params[:show_closed]
      logger.info "Showing also closed"
      person.listings.visible_to(@current_user, @current_community).order("created_at DESC").paginate(:per_page => per_page, :page => page)
    else
      logger.info "Showing only open"
      person.listings.currently_open.visible_to(@current_user, @current_community).order("created_at DESC").paginate(:per_page => per_page, :page => page)
    end
  end

  def grade_image_class(grade)
    "feedback_average_image_#{grade_number(grade).to_s}"
  end

  def grade_text(grade, full_description = true)
    t("people.#{full_description ? 'profile_feedback' : 'show'}.#{Testimonial::GRADES[grade_number(grade) - 1][0]}")
  end

  def grade_number(grade)
    if grade < 2
      return 1
    elsif (grade >= 2 && grade < 3)
      return 2
    elsif (grade >= 3 && grade < 3.5)
      return 3
    elsif (grade >= 3.5 && grade < 4.5)
      return 4
    else
      return 5
    end
  end

  def grade_number_profile(percentage)
    if percentage < 50
      return 1
    elsif (percentage >= 50 && percentage < 65)
      return 2
    elsif (percentage >= 65 && percentage < 80)
      return 3
    elsif (percentage >= 80 && percentage < 90)
      return 4
    else
      return 5
    end
  end

  def help_text_class(field)
    case field
    when "terms"
      "hidden_description_terms"
    when "feedback_description"
      "hidden_description_feedback"
    else
       "hidden_description_terms"
    end
  end

  def encrypted_email_for_trustcloud(email)
    # Public RSA key of TrustCloud
    tcpublickey =  OpenSSL::PKey::RSA.new("-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDY1tLeY6qZtq8BqDnbArujYyjG\nwGPrkzLhyQMUX4ASW+912gf1RPRJVsuufGuhTYsP+biXxjWAI8rUX1k4YisiOK8u\nflUED8i5Zrpn7dR8NNGQc/A3LLjPzmaqW7g++5Q+iIoSCRYczsUxx6Bmo/a9YIFJ\nWWbeYnKh10eHN/JMewIDAQAB\n-----END PUBLIC KEY-----")
    # Make the string URL safe by changing some characters
    encrypted_email = Base64.encode64(tcpublickey.public_encrypt(email)).tr('+/=', '-_~')
  end

  # Returns the error message for a case where
  # the user is trying to create a new email-restricted tribe
  # but there's already a community with the
  # email provided.
  def restricted_tribe_already_exists_error_message(existing_community)
    t("communities.signup_form.existing_community_with_this_email", :community_category => t("communities.signup_form.for_#{existing_community.category}"), :link => self.class.helpers.link_to(t("communities.signup_form.here"), existing_community.full_url)).html_safe
  end

  def trustcard_class(person)
    if ! logged_in?
      "trustcard-upper"
    elsif person.location
      "trustcard-lower"
    else
      ""
    end
  end

end

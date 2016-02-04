module EmailHelpers
  # Maps a name to an email address. Used by email_steps

  def email_for(to)
    case to

    # add your own name => email address mappings here

    when /^#{capture_model}$/
      model($1).email

    when /^"(.*)"$/
      $1

    else
      to
    end
  end

  def find_email_with_subject(address, subject)
    unread_emails_for(address).find { |m| m.subject =~ Regexp.new(Regexp.escape(subject)) }
  end

  def user_should_have_email(person, subject)
    address = person.emails.first.address
    expect(find_email_with_subject(address, subject)).not_to be_nil
  end
end

World(EmailHelpers)

class ChangeBlacklistedUsernames < ActiveRecord::Migration
  
  def up
    blacklisted_usernames_in_database.each do |blacklisted_username|
      replacement = find_available_replacement(blacklisted_username)
      execute "UPDATE people SET username=#{sanitize(replacement)} WHERE username=#{sanitize(blacklisted_username)} LIMIT 1"
    end
  end

  def down
    # Cannot be meaningfully reversed
  end
  
  private
  
  def blacklisted_usernames_in_database
    blacklist = YAML.load_file("#{Rails.root}/config/username_blacklist.yml")  
    execute("SELECT username FROM people WHERE username IN(#{blacklist.map{ |x| sanitize(x) }.join(",")})").to_a.flatten
  end
  
  def sanitize(string)
    ActiveRecord::Base.sanitize(string)
  end
  
  def find_available_replacement(username)
    counter = 1
    loop do
      replacement = "#{username}#{counter}"
      return replacement unless username_exists?(replacement)
      counter += 1
    end
  end
  
  def username_exists?(username)
    execute("SELECT COUNT(username) FROM people WHERE username='#{username}'").to_a.flatten.first != 0
  end

end

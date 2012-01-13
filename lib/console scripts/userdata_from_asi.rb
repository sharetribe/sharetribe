# NOTE: THIS IS A SCRIPT FOR ASI CONSOLE (NOT KASSI)

# This script generates an yml file with all the user ids, encrypted_passwords and salts when it's run in ASI console

# This is needed when migrating a Kassi server from using ASI to standalone mode

userdata = {}

Person.all.each do |p|
  userdata[p.guid] = [p.encrypted_password, p.salt]
  0
end

File.open("userdata.yml", "w") do |file|
  file.write userdata.to_yaml
  0
end


#------------------------------------------------------------------------------------------


# THIS PART IS TO READ THE YML FILE TO KASSI DB IN KASSI CONSOLE

userdata = YAML::load_file "userdata.yml"

userdata.keys.each do |id|
  p = Person.find_by_id(id)
  if p.present?
    p.update_attribute(:encrypted_password, userdata[id][0])
    p.update_attribute(:password_salt, userdata[id][1])
  end
end
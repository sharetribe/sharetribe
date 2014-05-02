# encoding: utf-8

# This is mainly intended to be copy pasted to console to create and print out the wanted invitations to csv format
# After which they can be imported e.g. to OpenOffice spreadsheet and printed out to deal to people

# Do the invitations
community_id = 313
info_text = "generated invites to Parque Providencia"
filename = "invitations.csv"

384.times do
  Invitation.create(:community_id => community_id, :information => info_text)
end

ins = Invitation.where(:community_id => community_id ,:information => info_text)

# output in CSV
columns = 4
result = ""

column = 0
ins.each do |i|
  #result += "parqueprovidencia.sharetribe.com código: #{i.code},"
  result += "#{i.code},"
  column += 1
  if column == columns
    result += "\n"
    column = 0
  end
  0
end
result += "\n"

File.open(filename, "w") do |file|
  file.write result
  0
end



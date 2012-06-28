object @person
attributes :id, :username, :given_name, :family_name, :locale, :phone_number, :description
child :communities do
  extends "api/communities/show"
end
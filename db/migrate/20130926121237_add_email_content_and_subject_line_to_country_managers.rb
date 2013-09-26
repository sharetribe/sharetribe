class AddEmailContentAndSubjectLineToCountryManagers < ActiveRecord::Migration
  def change
    remove_column :country_managers, :subject_line
    remove_column :country_managers, :email_content
    add_column :country_managers, :subject_line, :string
    add_column :country_managers, :email_content, :text
    #remove_column :country_managers, :email_signature, :text
  end
end

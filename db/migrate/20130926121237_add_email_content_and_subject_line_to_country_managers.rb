class AddEmailContentAndSubjectLineToCountryManagers < ActiveRecord::Migration
  def change
    add_column :country_managers, :subject_line, :string unless column_exists? :country_managers, :subject_line
    add_column :country_managers, :email_content, :text unless column_exists? :country_managers, :email_content
    remove_column :country_managers, :email_signature if column_exists? :country_managers, :email_signature
  end
end

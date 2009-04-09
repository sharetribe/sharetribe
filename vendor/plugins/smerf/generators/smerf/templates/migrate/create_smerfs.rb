class CreateSmerfs < ActiveRecord::Migration
  def self.up
    # Create table to hold smerf form data
    create_table :smerf_forms, :primary_key => :id, :force => true do |t|
      t.string    :name,          :null => false
      t.string    :code,          :null => false
      t.integer   :active,        :null => false  
      t.text      :cache
      t.timestamp :cache_date
    end
    add_index :smerf_forms, [:code], :unique => true

    # Create link table between the <%= user_table_name %> and smerf_forms table 
    # which is used to record that the user completed and save the form
    create_table :<%= link_table_name %>, :primary_key => :id, :force => true do |t|
      t.integer :<%= user_table_fk_name %>,       :null => false
      t.integer :smerf_form_id, :null => false
      t.text    :responses,     :null => false
    end

    # Create table to store user responses to each of the questions on the form
    create_table :smerf_responses, :primary_key => :id, :force => true do |t|
      t.integer :<%= link_table_fk_name %>, :null => false
      t.string  :question_code,       :null => false
      t.text    :response,            :null => false
    end
    
  end

  def self.down
    drop_table :smerf_responses
    drop_table :<%= link_table_name %>
    drop_table :smerf_forms
  end
end

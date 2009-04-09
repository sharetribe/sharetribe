# This model class manages the smerf_responses DB table. It stores the users 
# responses to questions on a smerf form. 
# 
# The users responses to questions on a form are stored in the smerf_responses 
# table which stores a separate record for each response to a question. If a 
# question has multiple answers then multiple records will be created for the 
# question. Responses for a question can be found by using the unique question 
# code assigned within the form definition file. So for example if we had a 
# question with code 'g1q1' and the user selects two answers which have been 
# assigned code values 3 and 5 then two records will be created, i.e.
# 
#     g1q1, 3
#     g1q1, 5
#     
# This allows analysis of form responses via SQL. 

class SmerfResponse < ActiveRecord::Base
  validates_presence_of :<%= link_table_fk_name %>
  validates_presence_of :question_code
  validates_presence_of :response
  belongs_to :<%= link_table_model_name %> 
  
end

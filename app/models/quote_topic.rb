class QuoteTopic < ActiveRecord::Base
  set_table_name :quotes_topics

  belongs_to :quote
  belongs_to :topic
end

# == Schema Information
#
# Table name: quotes_topics
#
#  id       :integer          not null, primary key
#  quote_id :integer          not null
#  topic_id :integer          not null
#

class QuoteTopic < ActiveRecord::Base
  set_table_name :quotes_topics

  belongs_to :quote
  belongs_to :topic
end

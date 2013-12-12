# == Schema Information
#
# Table name: quotes
#
#  id                :integer          not null, primary key
#  body              :text             default(""), not null
#  author_id         :integer
#  tags              :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  source            :text
#  author_first_name :string(255)
#  author_last_name  :string(255)
#  author_full_name  :string(255)
#

class Quote < ActiveRecord::Base
  attr_accessible :author_id, :body, :tags, :source, :author_first_name, :author_last_name, :author_full_name

  # before_save :initialize_full_name
  before_save :initialize_first_and_last_names
  before_save :associate_with_author

  belongs_to :author

  has_and_belongs_to_many :topics, uniq: true

  serialize :tags

  validates_presence_of :body

  searchable do
    string :author_name do
      author_full_name rescue ''
    end

    integer :author_id

    text :author_name, boost: 17.0 do
      author_full_name rescue ''
    end
    text :source, boost: 2.0
    text :body, boost: 3.0
    text :tags, boost: 17.0
  end

  def author_name
    return author.name if author_id.present?
    return ''
  end

  # def author_full_name
  #   [self.author_first_name, self.author_last_name].join(' ').downcase.titleize.strip
  # end

  def author_first_name=(value)
    write_attribute(:author_first_name, value.strip) if value.present?
  end

  def author_last_name=(value)
    write_attribute(:author_last_name, value.strip) if value.present?
  end

  def body=(raw)
    value = raw.gsub(/(\u00e2\u0080\u0099|\u0027)/, "'").gsub(/[\u201c\u201d]/, '"')
    write_attribute(:body, value)
  end

  def tags=(value)
    array = if value.is_a?(Array)
      value
    else
      value.to_s.scan(/\w+/)
    end

    write_attribute(:tags, array)
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << %w(author_full_name source body tags)
      all.each do |quote|
        csv << [quote.author_full_name, quote.source, quote.body, quote.tags.join(',')]
      end
    end
  end

  def initialize_full_name
    full_name = [self.author_first_name, self.author_last_name].join(' ').downcase.titleize.strip
    write_attribute(:author_full_name, full_name) unless self.author_full_name.present?
  end

  def initialize_first_and_last_names
    first_name, last_name = self.author_full_name.split(' ')
    if self.author_first_name.blank? and self.author_last_name.blank?
      write_attribute(:author_first_name, first_name)
      write_attribute(:author_last_name, last_name)
    end
  end

  protected

    def associate_with_author
      if self.author_full_name.present?
        author = Author.find_or_create_by_name(self.author_full_name)
        write_attribute(:author_id, author.id)
      end
    end
end

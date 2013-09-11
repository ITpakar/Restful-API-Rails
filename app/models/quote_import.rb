require "em-synchrony"
require "em-synchrony/fiber_iterator"
require "thread"

class QuoteImport
  # switch to ActiveModel::Model in Rails 4
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    EM.synchrony do
      if EM::Synchrony::FiberIterator.new(imported_quotes, 250).map(&:valid?).all?
      # if imported_quotes.map(&:valid?).all?
        Quote.destroy_all
        QuoteTopic.destroy_all
        DatabaseCleaner.clean_with(:truncation, :only => %w(quotes quotes_topics))
        Quote.import imported_quotes
        Quote.index
        Sunspot.commit
        # EM::Synchrony::FiberIterator.new(imported_quotes, 100).each(&:save!)
        # imported_quotes.each(&:save!)
      else
        EM::Synchrony::FiberIterator.new(imported_quotes, 250).each_with_index do |quote, index|
        # imported_quotes.each_with_index do |quote, index|
          quote.errors.full_messages.each do |message|
            errors.add :base, "Row #{index+2}: #{message}"
          end
        end
      end

      EM::Synchrony::FiberIterator.new(Quote.all, 250).each do |quote|
        if quote.author_full_name.present?
          author = Author.find_or_initialize_by_name(quote.author_full_name)
          author.first_name = quote.author_first_name
          author.last_name = quote.author_last_name
          author.save
          quote.author_id = author.id
          quote.save
        end

        quote.tags.each do |topic_name|
          topic = Topic.find_or_create_by_name(topic_name.titleize)
          quote.topics << topic unless quote.topics.include?(topic)
        end
      end

      @success = true
      EM.stop
    end

    return @success
  end

  def imported_quotes
    @imported_quotes ||= load_imported_quotes
  end

  def load_imported_quotes
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    rows = (2..spreadsheet.last_row)
    quotes = []
    EM::Synchrony::FiberIterator.new(rows, 250).each do |i|
    # rows.each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      quote = Quote.new
      quote.attributes = row.to_hash.slice(*Quote.accessible_attributes)
      quote.initialize_full_name
      quotes << quote if quote.valid?
    end
    return quotes
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path)
    when ".xls" then Roo::Excel.new(file.path)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end

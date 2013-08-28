namespace :author do
  desc "Copy username to store name."
  task :process_full_name => :environment do
    quotes = Quote.all
    quotes.each do |quote|
      full_name = [quote.author_first_name, quote.author_last_name].join(' ').downcase.titleize.strip
      quote.write_attribute(:author_full_name, full_name)    
    end
  end  
end
class AddAuthorFullNameToQuotes < ActiveRecord::Migration
  def up
    add_column :quotes, :author_full_name, :string

    Quote.all.each do |quote|
      full_name = [quote.author_first_name, quote.author_last_name].join(' ').downcase.titleize.strip
      quote.update_attribute(:author_full_name, full_name)
    end
  end

  def down
    remove_column :quotes, :author_full_name
  end
end

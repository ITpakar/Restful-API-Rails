class Admin::QuotesController < ApplicationController
  def index
    @quotes = Quote.order('author_last_name ASC, author_first_name ASC, id ASC').page(params[:page]).per(20)
  end

  def new
    @quote_import = QuoteImport.new
  end

  def create
    @quote_import = QuoteImport.new(params[:quote_import])
    if @quote_import.save
      redirect_to admin_quotes_url, notice: "Imported quotes successfully."
    else
      render :new
    end
  end
end

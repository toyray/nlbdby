class BooksController < ApplicationController
  def new
    @book = Book.new
  end

  def create
    brn = params[:book][:brn]
    book = NLBService.new.import_book(brn)
    if book.nil?
      flash[:error] = 'No book with this BRN found.'
    elsif book.unavailable?
      flash[:error] = 'Book is not available for borrowing in any library.'
    end
    @book = Book.new
    render :new
  end
end

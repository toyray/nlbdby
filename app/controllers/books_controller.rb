class BooksController < ApplicationController
  def index
    @books = Book.all.order(:call_no)
  end

  def show
    @book = Book.find(params[:id])
  end

  def new
    @book = Book.new
  end

  def create
    brn = params[:book][:brn]
    if Book.where(brn: brn).exists?
      flash[:error] = 'A book with this BRN has already been imported.'
    else
      book = NLBService.new.import_book(brn)
      if book.nil?
        flash[:error] = 'No book with this BRN found.'
      elsif book.unavailable?
        flash[:error] = 'Book is not available for borrowing in any library.'
      else
        book.save
        @book = book
        redirect_to book_path(@book) and return
      end
    end
    @book = Book.new
    render :new
  end
end

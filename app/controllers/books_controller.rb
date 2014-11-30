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
    @book, error = Book.import(params[:book][:brn])
    if @book
      redirect_to book_path(@book) and return
    else
      flash[:error] = error
      @book = Book.new
      render :new
    end
  end

  def import
    file = params[:book][:file]
    yaml = file.read
    file.close
    errors = Book.import_from_yaml(yaml)
    p errors
    redirect_to books_path
  end
end

class BooksController < ApplicationController
  def index
    @q = Book.search(params[:q])
    @books = @q.result.includes(:meta).includes(:library_books).uniq.paginate(:page => params[:page], :per_page => 15).order(:call_no)
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
    errors = Book.delay.import_from_yaml(yaml)
    redirect_to books_path
  end

  def export
    filename = "books#{Time.now.strftime('%Y%m%d')}.yaml" 
    send_data(Book.export_to_yaml, filename: filename, type: 'application/yaml')
  end
end

class BooksController < ApplicationController
  def index
    
    params[:q] ||= {}
    search_params = params[:q].dup

    # Ransack currently doesn't work nicely with scopes using boolean arguments so manually constructing search now
    if search_params.fetch(:library_count_eq, nil) == "-1"
      search_params.delete(:library_count_eq)
      search_params[:library_count_not_eq] = 1
    end

    # Search for all books that have not been borrowed if no status is selected
    if search_params.fetch(:meta_status_eq, "").blank?
      search_params.delete(:meta_status_eq)
      search_params[:meta_status_not_eq] = :borrowed
    end

    @q = Book.search(search_params)
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
      flash[:error] = t("activerecord.errors.models.book.#{error}")
      @book = Book.new
      render :new
    end
  end

  def import
    file = params[:book][:file]
    yaml = file.read
    file.close
    Book.import_from_yaml(yaml)
    redirect_to books_url
  end

  def export
    filename = "books#{Time.now.strftime('%Y%m%d')}.yaml" 
    send_data(Book.export_to_yaml, filename: filename, type: 'application/yaml')
  end

  def queue_update
    @book = Book.find(params[:id])
    @book.queue_update
    redirect_to books_url
  end

  def borrow
    @book = Book.find(params[:id])
    @book.meta.borrow
    redirect_to books_url
  end

  def browse
    @book = Book.find(params[:id])
    @book.meta.browse
    redirect_to books_url
  end  
end

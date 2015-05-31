class BooksController < ApplicationController
  def index
    params[:q] ||= {}
    search_params = build_search_params(params[:q])
    session[:search_library_id] =  search_params.fetch(:library_books_library_id_eq, nil)
    session.delete(:search_library_id) if session[:search_library_id].blank?

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
      flash[:alert] = t("activerecord.errors.models.book.#{error}")
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
    js false
    filename = "books#{Time.now.strftime('%Y%m%d')}.yaml"
    send_data(Book.export_to_yaml, filename: filename, type: 'application/yaml')
  end

  def queue_update
    @book = Book.find(params[:id])
    @book.queue_update
    render_row_or_redirect_index
  end

  def borrow
    @book = Book.find(params[:id])
    @book.meta.borrow
    render_row_or_redirect_index
  end

  def browse
    @book = Book.find(params[:id])
    @book.meta.browse
    render_row_or_redirect_index
  end

  def rate
    @book = Book.find(params[:id])
    @book.meta.rating = params[:rating]
    @book.meta.save
    respond_to do |format|
      format.json { render nothing: true, status: :ok }
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    remove_row_or_redirect_index
  end

  def revert_to_new
    @book = Book.find(params[:id])
    @book.meta.revert
    render_row_or_redirect_index
  end

  def toggle_starred
    @book = Book.find(params[:id])
    @book.meta.toggle!(:starred)
    render_row_or_redirect_index
  end

  def archive
    @book = Book.find(params[:id])
    @book.meta.archive
    remove_row_or_redirect_index
  end

  def summary
    respond_to do |format|
      format.js { js false }
    end
  end

  private
  def render_row_or_redirect_index
    respond_to do |format|
      format.js { render_row }
      format.html { redirect_to books_url }
    end
  end

  def render_row
    js false
    render partial: 'render_row'
  end

  def build_search_params(params)
    search_params = params.dup

    # Ransack currently doesn't work nicely with scopes using boolean arguments so manually constructing search now
    if search_params.fetch(:library_count_eq, nil) == "-1"
      search_params.delete(:library_count_eq)
      search_params[:library_count_not_eq] = 1
    end

    # Search for all books that have not been borrowed or archived if no status is selected
    if search_params.fetch(:meta_status_eq, "").blank?
      search_params.delete(:meta_status_eq)
      search_params[:meta_status_not_in] = [:borrowed, :archived]
    end

    # Search for regional books
    if search_params.fetch(:regional_only, nil).present?
      if search_params.delete(:regional_only) == "1"
        search_params[:non_regional_library_count_eq] = 0
      else
        search_params[:non_regional_library_count_not_eq] = 0
      end
    end

    # Search for available books
    if search_params.fetch(:available, nil).present?
      available = search_params.delete(:available) == "1"

      if search_params.fetch(:library_books_library_id_eq, nil).present?
        search_params[:library_books_available_eq] = available
      else
        if available
          search_params[:available_count_not_eq] = 0
        else
          search_params[:available_count_eq] = 0
        end
      end
    end

    # Search by library_count
    library_count = search_params.delete(:library_count).to_i
    case library_count
    when -1
      search_params[:library_count_lt] = 2
    when -2
      search_params[:library_count_in] = 2..5
    when -3
      search_params[:library_count_gt] = 5
    end

    search_params
  end

  def remove_row_or_redirect_index
    respond_to do |format|
      format.js { remove_row }
      format.html { redirect_to books_url }
    end
  end

  def remove_row
    js false
    render :remove
  end
end

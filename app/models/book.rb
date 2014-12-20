class Book < ActiveRecord::Base
  has_one :meta, class_name: BookUserMeta
  has_many :library_books

  validates :brn, presence: true, uniqueness: true                      
  validates :author, length: { minimum: 0 }, allow_nil: false
  validates :title, presence: true
  validates :pages, presence: true
  validates :height, presence: true
  validates :call_no, presence: true

  attr_accessor :library_statuses,
                :valid_book

  after_create :create_book_user_meta

  after_save :create_new_library,
             :update_library_books

  state_machine :status, :initial => :completed do
    after_transition :completed => :queued, do: :update_availability_async
    before_transition :queued => :completed, do: :update_timestamps

    event :queue_update do
      transition :completed => :queued
    end

    event :finish_update do
      transition :queued => :completed
    end
  end
              
  def unavailable?
    library_statuses.nil? || library_statuses.empty?
  end

  def self.import(brn)
    if Book.where(brn: brn).exists?
      [nil, 'A book with this BRN has already been imported.']
    else
      book = NLBService.new.import_book(brn)
      if book.nil?
        [nil, 'No book with this BRN found.']
      elsif book.unavailable?
        [nil, 'Book is not available for borrowing in any library.']
      else
        book.update_timestamps
        book.save!
        [book, nil]
      end
    end
  end

  def self.import_from_yaml(books_yaml)
    begin
      books = Psych.load(books_yaml)
    rescue Psych::SyntaxError
      books = {}
    end
    
    errors = {}
    books.each do |brn, meta|
      book, error_message = Book.import(brn)
      if book && meta
        book.meta.update(meta)
      elsif error_message
        errors[brn] = error_message
      end
    end
    errors
  end

  def self.export_to_yaml
    books = Book.includes(:meta).order(:brn)
    books_hash = books.reduce({}) do |hash,  book|
      meta = book.meta.attributes.except!('id', 'book_id', 'updated_at', 'created_at')
      hash[book.brn.to_i] = meta
      hash
    end
    Psych.dump(books_hash)
  end

  def update_timestamps
    self.last_updated_at = Time.now
  end  

  def update_availability
    NLBService.new.update_book(self)
    self.finish_update
  end

  def update_availability_async
    self.delay.update_availability
  end

  private

  def create_book_user_meta
    BookUserMeta.create(book_id: id)
  end

  def create_new_library
    library_statuses.each { |ls| Library.find_or_create_by(name: ls[:library]) } unless library_statuses.nil?
  end

  def update_library_books
    unless library_statuses.nil?
      library_books = []
      library_statuses.each do |ls| 
        library = Library.where(name: ls[:library]).first
        lb = LibraryBook.find_or_initialize_by(library_id: library.id, book_id: self.id)
        lb.update_attributes(ls.except(:library))
        library_books << lb
      end
      self.library_books = library_books
    end
  end
end

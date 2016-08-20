class Book < ActiveRecord::Base
  has_one :meta, class_name: BookUserMeta, dependent: :destroy
  has_many :library_books, dependent: :destroy
  has_many :libraries, through: :library_books

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

  scope :browsed, -> { joins(:meta).merge(BookUserMeta.browsed) }
  scope :good_or_better, -> { joins(:meta).merge(BookUserMeta.good_or_better) }
  scope :queued, -> { where(status: :queued) }

  delegate :read?, to: :meta

  def unavailable?
    library_statuses.nil? || library_statuses.empty?
  end

  def self.import(brn)
    if Book.where(brn: brn).exists?
      [nil, :already_imported]
    else
      book = NLBServiceV3.new.import_book(brn)
      if book.nil?
        [nil, :invalid_brn]
      elsif book.unavailable?
        [nil, :unavailable]
      else
        book.update_timestamps
        if book.save
          [book, nil]
        else
          [nil, :save_failed]
        end
      end
    end
  end

  def self.import_from_yaml(books_yaml)
    begin
      books = Psych.load(books_yaml)
    rescue Psych::SyntaxError
      books = {}
    end

    books.each do |brn, meta|
      unless Book.where(brn: brn).exists?
        Book.delay.import_and_save(brn, meta)
      end
    end
  end

  def self.export_to_yaml
    books = Book.includes(:meta).order(:id)
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
    NLBServiceV2.new.update_book(self)
    self.finish_update
  end

  def update_availability_async
    self.delay.update_availability
  end

  def self.import_and_save(brn, meta)
    book, error = Book.import(brn)
    if book && meta
      book.meta.update(meta)
    elsif error && error != :already_imported
      ImportLogger.error(brn, error)
    end
  end

  def available?(library_id=nil)
    if library_id.present?
      library_books.where(library_id: library_id).first.try(:available) || false
    else
      available_count > 0
    end
  end

  def reference?(library_id=nil)
    if library_id.present?
      library_books.where(library_id: library_id).first.try(:reference) || false
    else
      # Reference should return false when no libraries are specified and at least one library has the book in the non-reference section
      !library_books.exists?(reference: false)
    end
  end

  private
  def create_book_user_meta
    BookUserMeta.create(book_id: id)
  end

  def create_new_library
    library_statuses.each { |ls| Library.find_or_create_by(name: ls[:library], regional: ls[:regional]) } unless library_statuses.nil?
  end

  def update_library_books
    unless library_statuses.nil?
      library_books = []
      library_statuses.each do |ls|
        library = Library.where(name: ls[:library]).first
        lb = LibraryBook.find_or_initialize_by(library_id: library.id, book_id: self.id)
        lb.update_attributes(ls.except(:library, :regional))
        library_books << lb
      end
      self.library_books = library_books
    end
  end
end

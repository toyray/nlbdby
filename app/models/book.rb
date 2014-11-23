class Book < ActiveRecord::Base
  has_one :meta, class_name: BookUserMeta
  has_many :library_books

  validates_presence_of :brn,
                        :title,
                        :author,
                        :pages,
                        :height,
                        :call_no

  validates_uniqueness_of :brn

  attr_accessor :library_statuses,
                :valid_book

  after_create  :create_book_user_meta,
                :create_new_library,
                :create_library_books

  def unavailable?
    library_statuses.nil? || library_statuses.empty?
  end

  private

  def create_book_user_meta
    BookUserMeta.create(book_id: id)
  end

  def create_new_library
    library_statuses.each { |ls| Library.find_or_create_by(name: ls[:library]) } unless library_statuses.nil?
  end

  def create_library_books
    unless library_statuses.nil?
      library_statuses.each do |ls| 
        library = Library.where(name: ls[:library]).first
        LibraryBook.create(library: library, book: self, available: ls[:available], singapore: ls[:singapore])
      end
    end
  end
end

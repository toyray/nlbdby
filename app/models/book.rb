class Book < ActiveRecord::Base
  validates_presence_of :brn,
                        :title,
                        :author,
                        :pages,
                        :height,
                        :call_no

  attr_accessor :library_statuses,
                :valid_book

  after_create :create_book_user_meta

  def unavailable?
    library_statuses.nil? || library_statuses.empty?
  end

  private

  def create_book_user_meta
    BookUserMeta.create(book_id: id)
  end
end

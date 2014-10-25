class Book < ActiveRecord::Base
  validates_presence_of :brn,
                        :title,
                        :author,
                        :pages,
                        :height,
                        :call_no

  attr_accessor :library_statuses,
                :valid_book
end

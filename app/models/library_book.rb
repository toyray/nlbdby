class LibraryBook < ActiveRecord::Base
  belongs_to :library
  belongs_to :book

  delegate :name, to: :library, prefix: true
end

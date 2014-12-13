class LibraryBook < ActiveRecord::Base
  belongs_to :library
  belongs_to :book
  counter_culture :book, column_name: Proc.new { |model| model.available? ? 'available_count' : nil }
  counter_culture :book, column_name: "library_count"

  delegate :name, to: :library, prefix: true
end

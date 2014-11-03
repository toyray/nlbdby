class Library < ActiveRecord::Base
  validates_presence_of :name

  def self.available?(library_name)
    !(library_name == 'Repository Used Book Collection' || library_name.start_with?('Lee Kong Chian Reference Library'))
  end
end

class Library < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :regional, inclusion: [true, false]

  def self.available?(library_name)
    !(library_name == 'Repository Used Book Collection' || library_name.start_with?('Lee Kong Chian Reference Library'))
  end

  def self.regional?(library_name)
    library_name.include?('Regional')
  end

  scope :non_regional, -> { where(regional: false) }
end

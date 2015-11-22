class Library < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :regional, inclusion: [true, false]

  def self.available?(name)
    !(name == 'Repository Used Book Collection' || name.start_with?('Lee Kong Chian Reference Library'))
  end

  def self.regional?(name)
    name.include?('Regional')
  end

  def self.non_reference?(name)
    name == 'library@orchard'
  end

  scope :non_regional, -> { where(regional: false) }
end

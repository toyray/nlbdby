class BookUserMeta < ActiveRecord::Base
  belongs_to :book

  state_machine :status, :initial => :new do
    before_transition [:new, :browsed] => :borrowed, do: :reset_rating

    event :browse do
      transition :new => :browsed
    end

    event :borrow do
      transition [:new, :browsed] => :borrowed
    end
  end

  private

  def reset_rating
    self.rating = 0
  end
end

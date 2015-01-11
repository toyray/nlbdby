class BookUserMeta < ActiveRecord::Base
  belongs_to :book

  state_machine :status, :initial => :new do
    before_transition [:new, :browsed] => :borrowed, do: :reset_rating_and_starred

    event :browse do
      transition :new => :browsed
    end

    event :borrow do
      transition [:new, :browsed] => :borrowed
    end

    event :revert do
      transition [:borrowed, :browsed] => :new
    end
  end

  private

  def reset_rating_and_starred
    self.rating = 0
    self.starred = false
    true
  end
end

class BookUserMeta < ActiveRecord::Base
  belongs_to :book

  state_machine :status, :initial => :new do
    event :browse do
      transition :new => :browsed
    end

    event :borrow do
      transition [:new, :browsed] => :borrowed
    end
  end
end

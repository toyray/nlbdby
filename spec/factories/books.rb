FactoryGirl.define do
  factory :book do
    sequence(:brn)
    title "Good Book"
    author "Good Writer"
    pages 100
    height 21
    call_no "959.959"
  end
end

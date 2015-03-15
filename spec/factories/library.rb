FactoryGirl.define do
  factory :library do
    sequence(:name) { |n| "Good Library #{n}z" }
    regional false
  end
end

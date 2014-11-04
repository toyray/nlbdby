FactoryGirl.define do
  factory :book do
    sequence(:brn)
    title 'Good Book'
    author 'Good Writer'
    pages 100
    height 21
    call_no '959.959'

    factory :library_status do
      skip_create
      transient do
        library 'Good Library'
        available true
      end
    end
  end

  trait :without_library_statuses do
    library_statuses []
  end

  trait :with_library_statuses do
    library_statuses [ FactoryGirl.build(:library_status)] 
  end
end

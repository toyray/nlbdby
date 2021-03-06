FactoryGirl.define do
  factory :book do
    sequence(:brn)
    title 'Good Book'
    author 'Good Writer'
    pages 100
    height 21
    call_no '959.959'
  end

  factory :library_status, class: Hash do
    skip_create

    sequence(:library) { |n| "Good Library #{n}" }
    available true
    regional false
    singapore true
    reference true

    initialize_with { attributes }
  end  

  trait :without_library_statuses do
    library_statuses []
  end

  trait :with_library_statuses do
    transient do
      library_status_count 1
      regional false
    end

    after :build do |object, evaluator|
      object.library_statuses = FactoryGirl.create_list(:library_status, evaluator.library_status_count, regional: evaluator.regional)
    end
  end

  trait :borrowed do
    after :create do |object, _|
      object.meta.borrow
    end
  end
end

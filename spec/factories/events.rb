FactoryGirl.define do
  factory :event do
    name          "Event"
    specificity   "day"
    starts_at     { Date.today }
    ends_at       { Date.today + 1.month }
    creator
  end
end

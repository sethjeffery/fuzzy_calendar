FactoryGirl.define do
  factory :authentication do
    sequence      :uid
    provider      "facebook"
    user
  end
end

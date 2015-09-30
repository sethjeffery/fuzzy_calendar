FactoryGirl.define do
  factory :user, aliases: [:creator] do
    name    { Faker::Name.name }
    email   { Faker::Internet.email }
  end
end

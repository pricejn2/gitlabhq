FactoryBot.define do
  factory :redirect_route do
    sequence(:path) { |n| "redirect#{n}" }
    source factory: :group
  end
end

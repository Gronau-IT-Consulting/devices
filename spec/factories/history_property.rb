FactoryGirl.define do
  factory :history_property, aliases: %w(history_status) do
    uri   "https://api.lelylan.com/properties/#{Settings.resource_id}"
    value 'on'
  end

  factory :history_intensity, parent: :history_property do
    uri   "https://api.lelylan.com/properties/#{Settings.another_resource_id}"
    value '100'
  end
end

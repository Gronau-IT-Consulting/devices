class Property
  include Mongoid::Document
  store_in session: 'types'

  field :resource_owner_id
  field :name
  field :default, default: ''
  field :accepted, type: Array, default: []
end

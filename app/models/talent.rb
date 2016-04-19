class Talent
  include Mongoid::Document

  field :name
  field :key
  field :icon
  field :type

  field :duration
  field :mana_cost
  field :health_cost
  field :resource1
  field :resource2
  field :resource3

  has_and_belongs_to_many :units, class_name: 'Unit::Base'
end

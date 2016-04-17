class Species
  include Mongoid::Document

  field :name
  field :key
  field :home_planet
  field :description

  has_many :units, class_name: 'Unit::Base'
end

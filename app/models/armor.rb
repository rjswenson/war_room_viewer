class Armor
	include Mongoid::Document

	field :name
  field :key
	field :type
	field :icon

  field :strength1
  field :strength2
  field :weakness1
  field :weakness2

  field :description

  has_many :units, class_name: 'Unit::Base'
end
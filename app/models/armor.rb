class Armor
	include Mongoid::Document

	field :name
  field :key
	field :type
	field :icon

  has_many :units, class_name: 'Unit::Base'
end
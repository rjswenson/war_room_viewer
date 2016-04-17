class Game
  include Mongoid::Document

  field :key
  field :name
  field :year
  field :tags

  index({ name: 1 }, { background: true })
  index({ key: 1 }, { background: true })

  has_many :units, class_name: 'Unit::Base'
end
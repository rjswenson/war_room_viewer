class Ability
  include Mongoid::Document
  
  field :name
  field :key
  field :description
  field :position
  
  belongs_to :unit
end
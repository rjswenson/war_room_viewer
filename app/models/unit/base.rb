class Unit	
	class Base
	  include Mongoid::Document

	  field :portrait
	  field :concept_art

	  field :name
	  field :category
	  field :subcategory
	   
	  field :damage_type
	  field :damage_value
	  
	  field :hit_points
	  field :beats
	  field :loses_to
	   
	  has_many :abilities
	  has_one :armor
	end
end
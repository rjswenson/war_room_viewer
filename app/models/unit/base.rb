module Unit
	class Base
		include Mongoid::Document
	  include Mongoid::Paperclip
	  include Mongoid::Paranoia

	  field :name
	  field :key

	  field :size
	  field :pop_cost#, type: Float
	  field :resource_1 # minerals
	  field :resource_2 # gas
	  field :resource_3 # special?

	  field :hitpoints#, type: Float
	  field :shield#, type: Float
	  field :armor_value

	  field :g_attack
	  field :g_attack_dps#, type: Float
	  field :a_attack
	  field :a_attack_dps#, type: Float
	  field :attack_cd
	  field :attack_mod_1
	  field :attack_mod_2
	  field :ground_attack_range#, type: Float
	  field :air_attack_range#, type: Float

	  field :max_level#, type: Integer
	  field :sight#, type: Float
	  field :notes

	  field :build_time#, type: Float

	  belongs_to :game
	  belongs_to :species
	  belongs_to :armor, class_name: 'Armor'

	  field :images, type: Hash

	  has_and_belongs_to_many :talents
	end
end
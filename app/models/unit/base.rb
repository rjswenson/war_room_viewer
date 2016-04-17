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

	  # has_many :abilities
	  belongs_to :game
	  belongs_to :species
	  belongs_to :armor, class_name: 'Armor'

	  has_and_belongs_to_many :talents

	  PAPERCLIP_SETTINGS = {
	    'development' => {
	      :path   => ':rails_root/tmp/import/images/processed/:style-:altered_image_filename',
	      :url    => '/product_images/:style-:altered_image_filename'
	    },

	    'test' => {
	      :path   => ':rails_root/tmp/import/test/images/processed/:style-:altered_image_filename',
	      :url    => '/product_images/:style-:altered_image_filename'
	    }
	  }

	  has_mongoid_attached_file :asset, {
    :styles => {
      :icon => { :geometry => "80x95&", :processors => [:cropper, :quantizer], :format => :png, :quant_quality => "65-80" },
      :detail => { :geometry => "315x375&", :processors => [:cropper], :format => :png },
      :original => { :geometry => "1275x1515", :processors => [:cropper], :format => :png }
    }
  }.merge(PAPERCLIP_SETTINGS[Rails.env])

  validates_attachment_content_type :asset, :content_type => ["image/png", "image/jpg", "image/jpeg"]
	end
end
class Image
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Paranoia

  field :last_imported_at, type: Integer
  field :original_filename
  field :original_timestamp
  field :original_hash
  field :image_hash

  index(deleted_at: -1)

  PAPERCLIP_SETTINGS = {
    'development' => {
      :path   => ':rails_root/tmp/import/images/processed/:style-:unit_image.:extension',
      :url    => '/unit_images/:style-:unit_image.:extension'
    },

    'test' => {
      :path   => ':rails_root/tmp/import/test/images/processed/:style-:unit_image.:extension',
      :url    => '/unit_images/:style-:unit_image.:extension'
    }
  }

  has_mongoid_attached_file :asset, {
    :styles => {
      :icon => { :geometry => "80x95&", animated: true, format: 'GIF' },
      :preview => {:geometry => "200x200&", processors: [:cropper], format: :png },
      :detail => { :geometry => "315x375&", animated: true, format: 'GIF' },
      :original => { :geometry => "1275x1515", animated: true, format: 'GIF' }
    }
  }.merge(PAPERCLIP_SETTINGS[Rails.env])

  validates_attachment_content_type :asset, :content_type => ["image/gif", "image/gifv", "image/png", "image/jpg", "image/jpeg"]
end
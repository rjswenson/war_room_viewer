class Video
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Paranoia

  field :last_imported_at, :type => Integer
  field :original_filename
  field :original_timestamp
  field :video_hash

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
      :mp4 => { :geometry => "720x480#", :format => 'mp4',
                  :convert_options => {:output => {:"b:v" => '1536k'}} },
      :thumbnail => { :geometry => "720x480#", :format => 'png', :time => 10 }
    }, :processors => [:ffmpeg] }.merge(PAPERCLIP_SETTINGS[Rails.env])

  validates_attachment_file_name :asset, :matches => [/mov\Z/, /mp4\Z/]
end

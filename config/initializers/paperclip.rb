Paperclip.options[:log] = false


Paperclip.interpolates :name do |attachment, style|
  attachment.instance.name
end

Paperclip.interpolates :processed_name do |attachment, style|
  attachment.instance.name.gsub(' ', '_').gsub('+', '')
end

Paperclip.interpolates :generated_filename do |attachment, style|
  attachment.instance.generated_filename
end

Paperclip.interpolates :clean_video_name do |attachment, style|
  attachment.instance.original_filename.split("_V")[0] + "_V"
end

Paperclip.interpolates :key do |attachment, style|
  attachment.instance.key
end

Paperclip.interpolates :altered_image_filename do |attachment, style|
  attachment.instance.original_filename.match(/([-A-Za-z0-9]+_)?[-A-Za-z0-9]+_[-a-zA-Z0-9]+_[PSA](_[0-9]+)?/).to_s + ".png"
end

Paperclip.interpolates :timestamp do |attachment, style|
  attachment.instance_read(:updated_at).to_i
end

# Turn off spoof detection
# https://github.com/thoughtbot/paperclip/issues/1429
# require 'paperclip/media_type_spoof_detector'
# module Paperclip
#   class MediaTypeSpoofDetector
#     def spoofed?
#       false
#     end
#   end
# end
Paperclip.options[:log] = false

Paperclip.interpolates :name do |attachment, style|
  attachment.instance.name
end

# Paperclip.interpolates :clean_video_name do |attachment, style|
#   attachment.instance.original_filename.split("_V")[0] + "_V"
# end

Paperclip.interpolates :unit_image do |attachment, style|
  attachment.instance.original_filename.match(/[-A-Za-z0-9]+_[PM]_\d/i).to_s
end

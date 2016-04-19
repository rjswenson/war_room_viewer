module Display
  module ImageHelper
    def image_path_or_missing(image, quality = "detail")
      image_path(image, quality) || "missing.jpg"
    end

    def image_path(image, quality = "detail")
      return nil unless image
      if Rails.env.development?
        path = Rails.root.join('public', 'unit_images', image[quality]).to_s
      else
        path = open(image[quality].to_s)
      end
      unless ([String, Tempfile].include?(path.class) && File.exists?(path)) || path.class == StringIO
        return nil
      end
      path
    end

    def media_url(item, type)
      if item.try("#{type}_file_name".to_sym)
        image_tag(item.send(type).url(:icon))
      else
        nil
      end
    end
  end
end
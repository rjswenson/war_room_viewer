module Importer
  module MediaImport
    def before_media
      p 'starting product images and videos'
      @unit_images = {}
      @unit_videos = {}
      @imported_images = Set.new
      @imported_videos = Set.new
    end

    def map_media(file)
      if !ENV['NOIMAGES']
        original_name = File.basename(file)

        if original_name =~ /[-A-Za-z0-9]+_[PM]_\d\./i
          map_visual_data(file, Image)
        elsif original_name =~ /[-A-Za-z0-9]+_[V]_\d\./i
          map_visual_data(file, Video)
        else
          log "Media has invalid name: #{original_name}"
          return
        end
      end
    end

    def map_visual_data(media, klass)
      original_name = File.basename(media)

      begin
        desc = File.open(File.join(Rails.root, media))

        media_hash = Digest::SHA1.file(desc.path).to_s
        media_hash_type = "#{klass.to_s.downcase}_hash".to_sym
        hash = {
          original_filename: original_name,
          asset: desc,
          media_hash_type => media_hash
        }

        import(klass, media_finder_hash(hash), hash, hash.reject { |k, v| k == :asset })
        desc.close
      rescue
        log "Failed to import #{klass}: #{media}", $@[0..10].prepend($!.to_s)
        desc.close if desc
      end
      print klass.to_s.first
    end

    def media_finder_hash(media)
      {
        original_filename: media[:original_filename]
      }
    end

    def get_image_hash(hash)
      return nil if hash.blank?

      new_hash = {}
      # binding.pry
      hash.each do |key, value|
        if key == 'A'
          sort = lambda do |i|
            return 99  unless i = i.split('.').first.split('_')[3].to_i
            i
          end
          value.sort_by!(&sort)
        else
          value = [value.first]
        end

        new_hash[key] = value.map { |image| get_single_image_hash(image) }
      end

      new_hash
    end

    def get_single_image_hash(image)
      hash = {}
      %w{icon preview detail original}.each do |size|
        path = image.sub(/\/original-/, "/#{size}-")
        if Rails.env.development?
          hash[size] = Pathname.new(path).basename.to_s.split('?')[0]
        else
          hash[size] = path
        end
      end
      hash
    end

    def get_full_video_types(item_number)
      formatted_videos = {}
      if videos = @unit_videos[item_number]
        %w{mp4 thumbnail ogg}.each do |type|
          case type
          when "mp4"
            ext = ".mp4"
          when "ogg"
            ext = ".ogg"
          when "thumbnail"
            ext = ".png"
          end

          video = videos.first.sub(/\/original-/, "/#{type}-").sub(/\.mov\?/, "#{ext}?")
          if Rails.env.development?
            formatted_videos[type] = Pathname.new(video).basename.to_s.split('?')[0]
          else
            formatted_videos[type] = video
          end
        end
        [] << formatted_videos
      else
        []
      end
    end

    def after_media
      p 'done processing product images and videos'
      if !ENV['NOIMAGES']
        #fake delete old images and videos
        @imported_videos = nil
        @imported_images = nil
      end

      Video.all.each do |v|
        product_number = v.original_filename.split("_")[0]
        @unit_videos[product_number] ||= []
        @unit_videos[product_number] << v.asset.url
      end

      Image.all.each do |i|
        filename = i.original_filename.sub(/\.\w+$/, '')

        key, type, count = filename.split("_")

        @unit_images[key] ||= {}
        @unit_images[key][type] ||= []
        @unit_images[key][type] << i.asset.url
      end
    end
  end
end
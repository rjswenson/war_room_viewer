module Paperclip
  # Handles thumbnailing images that are uploaded.
  class Cropper < Thumbnail
    def initialize file, options = {}, attachment = nil
      super

      geometry             = options[:geometry]
      @file                = file
      @crop                = geometry[-1,1] == '#'
      @pad                 = geometry[-1,1] == '&'
      geometry             = geometry.chop if @pad
      @target_geometry     = Geometry.parse geometry
      @current_geometry    = Geometry.from_file @file
      @source_file_options = options[:source_file_options]
      @convert_options     = options[:convert_options]
      @whiny               = options[:whiny].nil? ? true : options[:whiny]
      @format              = options[:format]

      @source_file_options = @source_file_options.split(/\s+/) if @source_file_options.respond_to?(:split)
      @convert_options     = @convert_options.split(/\s+/)     if @convert_options.respond_to?(:split)

      @current_format      = File.extname(@file.path)
      @basename            = File.basename(@file.path, @current_format)

    end

    # Returns true if the +target_geometry+ is meant to be padded.
    def pad?
      @pad
    end

    # Returns the command ImageMagick's +convert+ needs to transform the image
    # into the thumbnail.
    def transformation_command
      scale, crop = @current_geometry.transformation_to(@target_geometry, crop?)
      trans = []
      trans << "-resize" << %["#{scale}"] unless scale.nil? || scale.empty?
      trans << "-gravity" << "center" << "-background" << "transparent" << "-extent" << %["#{scale}"] if pad?
      trans << "-crop" << %["#{crop}"] << "+repage" if crop
      trans << "-define" << "png:color-type=6" if @current_format == ".png"
      trans
    end
  end
end

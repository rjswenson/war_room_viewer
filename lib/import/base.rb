module Import
  class Base
    attr_accessor :import

    def initialize(import = nil)
      @import = import
    end

    def before
    end

    def after
    end

    def import(klass, finder_hash, instance_hash, compare_hash = nil)
      existing = klass.unscoped.where(finder_hash).first

      if using_paranoia(klass)
        instance_hash.merge!(:deleted_at => nil)
        compare_hash.merge!(:deleted_at => nil) if compare_hash
      end

      if existing && compare_hash
        if is_different?(existing, compare_hash)
          p "*updating*"
          p "OLD: #{existing.attributes} // NEW: #{compare_hash}"
          existing.update_attributes(instance_hash)
          existing
        end
      elsif existing
        existing.update_attributes(instance_hash)
        existing
      else
        klass.create!(instance_hash)
      end
    end

    def using_paranoia(klass)
      klass.fields.keys.include? "deleted_at"
    end

    def is_different?(record, compare_hash)
      record_hash = record.attributes.with_indifferent_access
      compare_hash.each do |k, v|
        return true unless record_hash[k] == v
      end

      false
    end

    def store_class_in_new_collection(klass)
      instance_variable_set("@original_#{klass.to_s.downcase}_collection", klass.collection)
      klass.store_in(:collection => "import_#{klass.to_s.downcase}")
      klass.collection.drop
    end

    def overwrite_original_collection(klass)
      original_collection = instance_variable_get("@original_#{klass.to_s.downcase}_collection")
      original_collection.drop
      klass.collection.rename(original_collection.name)
      klass.store_in(:collection => original_collection.name)
      klass.create_indexes
    end

    def report_record(field, record, current_import, type)
      type ||= ''
      type = type.to_s + ' '

      p "Invalid #{type.to_s}record missing #{field} field: " + record.to_s

      log("Invalid #{type.to_s}record missing #{field} field", record.to_s)
    end

    def sanitize_record(record, required_fields, current_import = nil, type = nil)
      required_fields.each do |field|
        if record[field].blank? && record[field] != false
          report_record(field, record, current_import, type)
          return false
        end
      end

      record
    end

    def log(message, detail = nil)
      @import.add_message(message, detail)
      @import.with(write: {w: 0}).save!
    end
  end
end

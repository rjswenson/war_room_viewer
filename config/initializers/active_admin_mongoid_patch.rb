module ActiveAdmin
  module Filters
    module FormtasticAddons
      def klass
        @object.class
      end

      def polymorphic_foreign_type?(method)
        false
      end

      def seems_searchable?
        false
      end
    end

    module ResourceExtension
      # This is to populate the values of textboxes with the previous values, or nil.
      # Without this, Rails tries to query the Mongoid::Criteria for the values, which doesn't work.
      def filters_sidebar_section
        ActiveAdmin::SidebarSection.new :filters, only: :index, if: ->{ active_admin_config.filters.any? } do
          search = params[:q].present? ? OpenStruct.new(params[:q]) : OpenStruct.new
          active_admin_filters_form_for search, active_admin_config.filters
        end
      end
    end
  end

  class ResourceController
    module DataAccess
      # For basic filtering - we could override the controllers directly to be less invasive if we wanted.
      def apply_filtering(chain)
        chain = chain.all
        params[:q].each do |key, value|
          value = value.gsub(/[\[\|\?\*\+\(\)\\]/, '') if value.kind_of?(String)
          # Strings
          if key =~ /^([\w\_\.]+)_contains$/ && value.present?
            field = $1
            regex = Regexp.new(value, true)
            chain = chain.where($1 => regex)
          elsif key =~ /^([\w\_\.]+)_equals$/ && value.present?
            chain = chain.where($1 => value)
          elsif key =~ /^([\w\_\.]+)_starts_with$/ && value.present?
            value = /^#{value}/i
            chain = chain.where($1 => value)
          elsif key =~ /^([\w\_\.]+)_ends_with$/ && value.present?
            value = /#{value}$/i
            chain = chain.where($1 => value)
          # Select Boxes
          elsif key =~ /^([\w\_\.]+)_in$/ && value.present?
            field = $1
            regex = Regexp.new(value, true)
            chain = chain.where($1 => regex)
          # Dropdown
          elsif key =~ /^([\w\_\.]+)_eq$/ && value.present?
            if key.include?('id') && value.kind_of?(String)
              searched_by = BSON::ObjectId.from_string(value)
            else
              searched_by = Regexp.new(value, true)
            end
            field = $1
            chain = chain.where($1 => searched_by)
          # Date
          elsif key =~ /^([\w\_\.]+)_(gteq|lteq)$/ && value.present?
            field = $1
            operator = $2.chop
            chain = chain.where($1 => {"$#{operator}" => DateTime.parse(value).to_time})
          elsif value.present?
            logger.debug "!!!!!!!!!!#{key} = #{value} not recognized and not added to search chain."
          end
        end if params[:q].present?
        chain
      end
    end
  end
  module Inputs
    class FilterDateRangeInput
      # Fixes date output so it's remembered
      def input_html_options(input_name = gt_input_name)
        current_value = @object.send(input_name)
        { size: 12,
          class: "datepicker",
          max: 10,
          value: current_value.respond_to?(:strftime) ? current_value.strftime("%Y-%m-%d") : current_value }
      end
    end
  end
end

module ActiveAdmin
  module Helpers
    module Collection
      def collection_size(collection)
        collection.try(:count) || 0
      end
    end
  end
end

module ActiveAdmin::ViewHelpers::DisplayHelper
  alias :pretty_format_before_symbol_hack :pretty_format
  def pretty_format(object)
    if object.is_a?(Symbol)
      object.to_s
    else
      pretty_format_before_symbol_hack(object)
    end
  end
end
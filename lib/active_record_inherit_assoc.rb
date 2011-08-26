require 'active_record'
require 'active_record/base'
require 'active_record/reflection'
require 'active_record/associations/association_proxy'
require 'active_record/associations/association_collection'

ActiveRecord::Base.valid_keys_for_has_many_association << :inherit
ActiveRecord::Base.valid_keys_for_has_one_association << :inherit
ActiveRecord::Base.valid_keys_for_belongs_to_association << :inherit


module ActiveRecord
  module Associations
    class AssociationProxy
      def conditions_with_value_inheritance
        # ActiveHash doesn't respond.
        return conditions_without_value_inheritance unless @reflection.klass.respond_to?(:merge_conditions)

        @reflection.klass.merge_conditions(attribute_inheritance_hash, conditions_without_value_inheritance)
      end

      alias_method_chain :conditions, :value_inheritance
      private
      def attribute_inheritance_hash
        return {} unless @reflection.options[:inherit]
        Array(@reflection.options[:inherit]).inject({}) { |hash, obj| hash[obj] = @owner.send(obj) ; hash }
      end
    end

    class AssociationCollection < AssociationProxy
      # this is *maybe* not the correct place to patch in, but it covers all the cases
      # without having to patch build, create, create!, etc
      def add_record_to_target_with_callbacks_with_value_inheritance(record, &block)
        attribute_inheritance_hash.each do |k, v|
          record[k] = v
        end
        add_record_to_target_with_callbacks_without_value_inheritance(record, &block)
      end

      alias_method_chain :add_record_to_target_with_callbacks, :value_inheritance
    end

    class HasOneAssociation < BelongsToAssociation
      def create_with_value_inheritance(attrs = {}, replace_existing = true)
        attrs ||= {}
        create_without_value_inheritance(attribute_inheritance_hash.merge(attrs), replace_existing)
      end

      def create_with_value_inheritance!(attrs = {}, replace_existing = true)
        attrs ||= {}
        create_without_value_inheritance!(attribute_inheritance_hash.merge(attrs), replace_existing)
      end

      def build_with_value_inheritance(attrs = {}, replace_existing = true)
        attrs ||= {}
        build_without_value_inheritance(attribute_inheritance_hash.merge(attrs), replace_existing)
      end
      [:create, :create!, :build].each { |sym| alias_method_chain sym, :value_inheritance }
    end
  end
end

require 'active_record'
require 'active_record/base'
require 'active_record/reflection'
require 'active_record/associations/association_proxy'
require 'active_record/associations/association_collection'

ActiveRecord::Base.valid_keys_for_has_many_association << :inherit
ActiveRecord::Base.valid_keys_for_has_one_association << :inherit
ActiveRecord::Base.valid_keys_for_belongs_to_association << :inherit

class ActiveRecord::Base
  # Makes the model inherit the specified attribute from a named association.
  #
  # parent_name - The Symbol name of the parent association.
  # options     - The Hash options to use:
  #               :attr - A Symbol or an Array of Symbol names of the attributes
  #                       that should be inherited from the parent association.
  #
  # Examples
  #
  #   class Post < ActiveRecord::Base
  #     belongs_to :category
  #     inherits_from :category, :attr => :account
  #   end
  #
  def self.inherits_from(parent_name, options = {})
    attrs = Array.wrap(options.fetch(:attr))

    before_validation do |model|
      parent = model.send(parent_name)

      attrs.each do |attr|
        model[attr] = parent[attr] if parent.present?
      end
    end
  end
end

module ActiveRecord
  module Associations
    AssociationProxy.class_eval do
      def conditions_with_value_inheritance
        return conditions_without_value_inheritance unless @reflection.klass.respond_to?(:sanitize_sql) # ActiveHash TODO test this!
        copied_merge_conditions(attribute_inheritance_hash, conditions_without_value_inheritance)
      end

      alias_method_chain :conditions, :value_inheritance

      private

      # copied from activerecord 2.3 to fix compatability with 3.0
      # Merges conditions so that the result is a valid +condition+
      def copied_merge_conditions(*conditions)
        segments = []

        conditions.each do |condition|
          unless condition.blank?
            sql = sanitize_sql(condition)
            segments << sql unless sql.blank?
          end
        end

        "(#{segments.join(') AND (')})" unless segments.empty?
      end

      def attribute_inheritance_hash
        return {} unless @reflection.options[:inherit]
        Array(@reflection.options[:inherit]).inject({}) { |hash, obj| hash[obj] = @owner.send(obj) ; hash }
      end
    end

    AssociationCollection.class_eval do
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

    HasOneAssociation.class_eval do
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

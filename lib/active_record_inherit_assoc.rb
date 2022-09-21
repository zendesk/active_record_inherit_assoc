require 'active_record'

module ActiveRecordInheritBuildAssocPrepend
  INHERIT_OPTIONS = %i[inherit inherit_allowed_list].freeze

  def valid_options(options)
    super + INHERIT_OPTIONS
  end
end

ActiveRecord::Associations::Builder::Association.singleton_class.prepend(ActiveRecordInheritBuildAssocPrepend)

module ActiveRecordInheritAssocPrepend
  def target_scope
    if inherited_attributes = attribute_inheritance_hash
      super.where(inherited_attributes)
    else
      super
    end
  end

  private

  def attribute_inheritance_hash
    return nil unless reflection.options[:inherit]
    inherit_allowed_list = reflection.options[:inherit_allowed_list]

    Array(reflection.options[:inherit]).each_with_object({}) do |association, hash|
      assoc_value = owner.send(association)
      assoc_value = Array(assoc_value).concat(inherit_allowed_list) if inherit_allowed_list
      hash[association] = assoc_value
      hash["#{through_reflection.table_name}.#{association}"] = assoc_value if reflection.options.key?(:through)
    end
  end

  def skip_statement_cache?(*)
    super || !!reflection.options[:inherit]
  end
end

ActiveRecord::Associations::Association.send(:prepend, ActiveRecordInheritAssocPrepend)

module ActiveRecordInheritPreloadAssocPrepend
  if ActiveRecord::VERSION::STRING < '5.2.0'
    def associated_records_by_owner(*)
      super.tap do |result|
        next unless inherit = reflection.options[:inherit]
        result.each do |owner, associated_records|
          filter_associated_records_with_inherit!(owner, associated_records, inherit)
        end
      end
    end
  else
    def associate_records_to_owner(owner, records)
      if inherit = reflection.options[:inherit]
        records = Array(records)
        filter_associated_records_with_inherit!(owner, records, inherit)
      end
      super
    end
  end

  def scope
    prescope = super

    if inherit = reflection.options[:inherit]
      Array(inherit).each do |inherit_assoc|
        owner_values = owners.map(&inherit_assoc)
        owner_values.compact!
        owner_values.uniq!
        owner_values.concat(reflection.options[:inherit_allowed_list]) if reflection.options[:inherit_allowed_list]
        prescope = prescope.where(inherit_assoc => owner_values)
      end
    end

    prescope
  end

  def filter_associated_records_with_inherit!(owner, associated_records, inherit)
    associated_records.select! do |record|
      Array(inherit).all? do |association|
        record_value = record.send(association)
        record_value == owner.send(association) || reflection.options[:inherit_allowed_list]&.include?(record_value)
      end
    end
  end
end

ActiveRecord::Associations::Preloader::Association.send(:prepend, ActiveRecordInheritPreloadAssocPrepend)

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

require 'active_record'

case ActiveRecord::VERSION::MAJOR
when 3
  ActiveRecord::Associations::Builder::HasMany.valid_options   << :inherit
  ActiveRecord::Associations::Builder::HasOne.valid_options    << :inherit
  ActiveRecord::Associations::Builder::BelongsTo.valid_options << :inherit
when 4
  ActiveRecord::Associations::Builder::Association.valid_options << :inherit
when 5
  # We can't add options into `valid_options` anymore.
  # Here are the possible solutions:
  #   * monkey patch Assocition::VALID_OPTIONS
  #   * prepend the `valid_options` method
  #   * create an Extension class and add it via ActiveRecord::Associations::Builder::Association.extensions
  #
  # I went with the first one out of simplicity.
  ActiveRecord::Associations::Builder::Association::VALID_OPTIONS << :inherit
end

module ActiveRecordInheritAssoc

  # When building an association with :inherit we inject a scope.
  # The scope will add the current objects attributes to all queries done with this association.
  module InheritedScoping
    def build(model, name, scope = nil, options = {}, &block)
      if options[:inherit]
        # TODO: we could support this with yielding to the original scope
        raise(
          ArgumentError,
          "Inherited assocations already use a scope, you cannot pass a scope when building it.\n" \
          "If you need this feature, do not use :inherit and define a combined scope manually"
        )
      elsif scope.is_a?(Hash) && inherit = scope[:inherit]
        inherit = Array(inherit) # can be symbol or array of symbols

        options = scope
        scope = -> (record) do
          if record # called on single record
            query = inherit.each_with_object({}) { |k, all| all[k] = record.send(k) }
            where(query)
          else # called at class level, so there is nothing we can do
            where(nil)
          end
        end
        reflection = super(model, name, scope, options, &block)

        # we want to be called with nil, so we override the sanity check rails added
        # https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1
        # without the preloader patch below this would be a terrible idea
        def reflection.check_preloadable!
          false
        end

        reflection
      else
        super
      end
    end
  end

  class << ActiveRecord::Associations::Builder::Association
    prepend InheritedScoping
  end

  # When we preloaded an unscoped association we did not filter in the sql,
  # so we have to filter the records that came back ... expensive
  module PreloadFilter
    def associated_records_by_owner(*args)
      super.tap do |result|
        next unless inherit = reflection.options[:inherit]
        result.each do |owner, associated_records|
          filter_associated_records_with_inherit!(owner, associated_records, inherit)
        end
      end
    end

    def filter_associated_records_with_inherit!(owner, associated_records, inherit)
      associated_records.select! do |record|
        Array(inherit).all? do |association|
          record.send(association) == owner.send(association)
        end
      end
    end
  end

  ActiveRecord::Associations::Preloader::Association.send(:prepend, PreloadFilter)
end

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

require 'active_record'

if ActiveRecord::VERSION::STRING < "3.1"
  raise 'this rails version is unsupported!'
elsif ActiveRecord::VERSION::STRING < "4.0"
  require 'active_record_inherit_assoc/ar_31_and_32'
else
  require 'active_record_inherit_assoc/ar_4'
end

require 'active_record_inherit_assoc/common'
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

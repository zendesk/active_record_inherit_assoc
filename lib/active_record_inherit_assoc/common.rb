ActiveRecord::Associations::Association.class_eval do
  def association_scope_with_value_inheritance
    if inherited_attributes = attribute_inheritance_hash
      association_scope_without_value_inheritance.where(inherited_attributes)
    else
      association_scope_without_value_inheritance
    end
  end

  alias_method_chain :association_scope, :value_inheritance

  def attribute_inheritance_hash
    return nil unless reflection.options[:inherit]
    Array(reflection.options[:inherit]).inject({}) { |hash, obj| hash[obj] = owner.send(obj) ; hash }
  end
end


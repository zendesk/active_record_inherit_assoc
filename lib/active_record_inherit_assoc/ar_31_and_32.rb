require 'active_record'

ActiveRecord::Associations::Builder::HasMany.valid_options   << :inherit
ActiveRecord::Associations::Builder::HasOne.valid_options    << :inherit
ActiveRecord::Associations::Builder::BelongsTo.valid_options << :inherit


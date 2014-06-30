require 'active_record'

# sorta hacky, but whatever.
ActiveRecord::Associations::Builder::Association.valid_options << :inherit


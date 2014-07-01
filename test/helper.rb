require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/rg'

require 'active_record'
ActiveRecord::Schema.verbose = false
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)
require_relative "schema"

require 'active_record_inherit_assoc'

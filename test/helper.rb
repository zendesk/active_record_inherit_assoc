require 'bundler'
Bundler.setup
Bundler.require

require 'minitest/autorun'
require 'active_support/test_case'


ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)
require File.expand_path("../schema", __FILE__)

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'active_record_inherit_assoc'

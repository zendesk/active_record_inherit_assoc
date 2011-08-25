require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require(:default, :development)

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'active_record_inherit_assoc'
require 'logger'
require 'shoulda'
require 'ruby-debug'
RAILS_ENV = "test"

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/test.log")
database_config = YAML.load_file(File.join(File.dirname(__FILE__), 'database.yml'))
ActiveRecord::Base.establish_connection(database_config['test'])
require 'schema'
require 'active_support/test_case'

ENV['RAILS_ENV'] = 'test'

require 'rails'
require 'sunspot_rails'
require 'solr_wrapper'

require 'sidekiq/testing'
Sidekiq::Testing.__test_mode = :fake

require_relative '../spec/dummy/config/environment'
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../spec/dummy/db/migrate', __dir__)]

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'sunspot_offline'

require 'active_support/testing/time_helpers'

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
  config.disable_monkey_patching!
end

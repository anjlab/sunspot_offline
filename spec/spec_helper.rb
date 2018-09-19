ENV['RAILS_ENV'] = 'test'

require 'rails'
require 'sunspot_rails'
require 'solr_wrapper'

require 'sidekiq/testing'
Sidekiq::Testing.__test_mode = :fake

require_relative '../spec/dummy/config/environment'

migrations_path = File.expand_path('../spec/dummy/db/migrate', __dir__)
if defined?(ActiveRecord::MigrationContext) # Rails 5.2
  migration_context = ActiveRecord::MigrationContext.new(migrations_path)
  migration_context.migrate if migration_context.needs_migration?
else
  ActiveRecord::Migrator.migrate(migrations_path) # Rails 5.0 - 5.1
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'sunspot_offline'

require 'active_support/testing/time_helpers'

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
  config.disable_monkey_patching!
end

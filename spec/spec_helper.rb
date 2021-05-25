ENV['RAILS_ENV'] = 'test'

require 'rails'
require 'active_record'
require 'active_record/migration'
require 'sunspot_rails'
require 'solr_wrapper'

require 'sidekiq/testing'
Sidekiq::Testing.__test_mode = :fake

require_relative '../spec/dummy/config/environment'

migrations_path = File.expand_path('../spec/dummy/db/migrate', __dir__)
if ::ActiveRecord.version < Gem::Version.create('5.2.0')
  ::ActiveRecord::Migrator.migrate(migrations_path)
elsif ::ActiveRecord.version < Gem::Version.create('6.0.0')
  ::ActiveRecord::MigrationContext.new(migrations_path).migrate
else
  ::ActiveRecord::MigrationContext.new(migrations_path, ::ActiveRecord::SchemaMigration).migrate
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'sunspot_offline'

require 'active_support/testing/time_helpers'

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
  config.disable_monkey_patching!
end

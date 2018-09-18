require 'ostruct'
require 'sunspot_offline/version'
require 'sunspot_offline/rails/railtie'
require 'sunspot_offline/sidekiq/index_worker'
require 'sunspot_offline/sidekiq/removal_worker'

module SunspotOffline
  class << self
    def configuration
      @configuration ||= OpenStruct.new(
        retry_delay: 1.hour,
        solr_error_callback: ->(_exception) {},
        filter_sidekiq_job_callback: ->(_job) { false }, # some Sidekiq jobs are allowed to fail and retry on their own
        index_job: Sidekiq::IndexWorker, # Sidekiq job which will handle index retries
        removal_job: Sidekiq::RemovalWorker, # Sidekiq job which will handle removal retries
        default_queue: 'default'
      )
    end

    def configure
      if block_given?
        yield(configuration)
        [SunspotOffline::Sidekiq::IndexWorker, SunspotOffline::Sidekiq::RemovalWorker].each do |worker|
          worker.sidekiq_options[:queue] = configuration.default_queue
        end
      end
    end

    def on_solr_error(exception)
      configuration.solr_error_callback.call(exception) if configuration.solr_error_callback
    end

    def filter_sidekiq_job?(job_class_name)
      configuration.filter_sidekiq_job_callback.call(job_class_name) if configuration.filter_sidekiq_job_callback
    end
  end
end

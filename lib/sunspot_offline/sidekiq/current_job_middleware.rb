require 'request_store'

module SunspotOffline
  module Sidekiq
    class CurrentJobMiddleware
      STORE_KEY = 'Sidekiq.CurrentJob'

      def initialize(*); end

      def call(worker, _job, _queue)
        RequestStore[STORE_KEY] = worker.class.name
        yield
      ensure
        RequestStore[STORE_KEY] = nil
      end

      def self.get
        RequestStore[STORE_KEY]
      end
    end
  end
end

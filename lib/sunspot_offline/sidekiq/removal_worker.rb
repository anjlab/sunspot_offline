require 'sidekiq'

module SunspotOffline
  module Sidekiq
    class RemovalWorker
      include ::Sidekiq::Worker

      def perform(model_class, ids)
        if ids.present?
          Sunspot.remove_by_id(model_class, Array(ids))
        else
          Sunspot.remove_all(model_class)
        end
      end
    end
  end
end

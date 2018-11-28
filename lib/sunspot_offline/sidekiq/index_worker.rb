require 'sidekiq'

module SunspotOffline
  module Sidekiq
    class IndexWorker
      include ::Sidekiq::Worker

      def perform(model_class, scope)
        klass = model_class.classify.constantize
        if klass.searchable?
          if scope.is_a?(Array)
            scope.each_slice(1000) { |slice| ::Sunspot.index(klass.where(id: slice)) }
          elsif scope.is_a?(Hash)
            klass.atomic_update(scope.with_indifferent_access)
          else
            klass.where(id: scope).take&.index
          end
        end
      end
    end
  end
end

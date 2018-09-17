require 'sunspot'
require 'sunspot_offline/sunspot/abstract_search'
require 'sunspot_offline/rsolr/client'
require 'sunspot_offline/sidekiq/current_job_middleware'

module SunspotOffline
  module Rails
    class Railtie < ::Rails::Railtie
      initializer 'sunspot_offline.init', before: 'sunspot_rails.init' do
        ::Sunspot::Search::AbstractSearch.prepend SunspotOffline::Sunspot::AbstractSearch

        ::RSolr::Client.prepend SunspotOffline::RSolr::Client

        ::Sidekiq.configure_server do |config|
          config.server_middleware do |chain|
            chain.add SunspotOffline::Sidekiq::CurrentJobMiddleware
          end
        end
      end
    end
  end
end

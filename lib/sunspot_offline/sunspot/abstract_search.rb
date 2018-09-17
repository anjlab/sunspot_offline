module SunspotOffline
  module Sunspot
    module AbstractSearch
      def execute
        super
      rescue RSolr::Error::ConnectionRefused, RSolr::Error::Http => ex
        @solr_result = {
          'response' => {
            'numFound' => -1,
            'start' => 0,
            'docs' => []
          },
          'facet_counts' => {
            'facet_queries' => {},
            'facet_fields' => {}
          },
          'grouped' => {}
        }
        SunspotOffline.configuration.on_handled_exception.call(ex)
        self
      end
    end
  end
end

module SunspotOffline
  module RSolr
    module Client
      def add(documents, opts = {})
        wrap_request(
          deletion: false,
          documents: -> { group_documents(documents.map { |doc| doc.field_by_name(:id).value }) }
        ) { super }
      end

      def delete_by_id(id, opts = {})
        wrap_request(deletion: true, documents: -> { group_documents(Array(id)) }) { super }
      end

      def delete_by_query(query, opts = {})
        wrap_request(deletion: true, documents: -> { removal_documents(query) }) { super }
      end

      private

      def wrap_request(deletion:, documents:)
        yield
      rescue StandardError => ex
        raise ex if raise_exception?

        job = deletion ? SunspotOffline.configuration.removal_job : SunspotOffline.configuration.index_job
        perform_at = Time.zone.now + SunspotOffline.configuration.retry_delay
        documents.call.each { |klass, list| job.perform_at(perform_at, klass, list) }
        SunspotOffline.on_solr_error(ex)
      end

      def raise_exception?
        sidekiq_job = SunspotOffline::Sidekiq::CurrentJobMiddleware.get
        !sidekiq_job.nil? && (fail_over_job?(sidekiq_job) || SunspotOffline.filter_sidekiq_job?(sidekiq_job))
      end

      def fail_over_job?(job_name)
        [SunspotOffline.configuration.index_job.name, SunspotOffline.configuration.removal_job.name].include?(job_name)
      end

      def group_documents(documents)
        documents
          .map { |id_text| id_text.split(' ') }
          .group_by(&:first)
          .map { |klass, list| [klass, list.map(&:last)] }
      end

      def removal_documents(query)
        [query == '*:*' ? [nil, nil] : [query.split(':').last, nil]]
      end
    end
  end
end

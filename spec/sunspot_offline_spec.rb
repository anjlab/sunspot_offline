require 'spec_helper'

RSpec.describe SunspotOffline do
  before(:each) do
    SunspotOffline::Sidekiq::IndexWorker.jobs.clear
    SunspotOffline::Sidekiq::RemovalWorker.jobs.clear
  end

  let(:user) { User.find_or_create_by(name: 'test user') }

  let(:user_id) { user.id.to_s }

  context 'with Solr online' do
    SOLR_INSTANCE = SolrWrapper.default_instance

    before(:all) { SOLR_INSTANCE.start }

    after(:all) { SOLR_INSTANCE.stop }

    it 'does not blocks indexing when solr is available', solr: true do
      SOLR_INSTANCE.with_collection(name: 'sunspot_offline') do
        expect { user.index }.not_to change(SunspotOffline::Sidekiq::IndexWorker.jobs, :size)
      end
    end
  end

  context 'failover' do
    before(:each) do
      allow_any_instance_of(RSolr::Client).to receive(:send_and_receive).and_raise(RuntimeError)
      travel_to Time.zone.local(2018, 1, 1, 12, 0, 0)
    end

    context 'for adding documents' do
      it 'queues request for a later execution' do
        expect { user.index }.to change(SunspotOffline::Sidekiq::IndexWorker.jobs, :size).by(1)

        expect(SunspotOffline::Sidekiq::IndexWorker.jobs.first['args']).to eq([User.name, [user_id]])
      end

      it 'queues request for a later execution with a given delay' do
        SunspotOffline.configure { |config| config.retry_delay = 24.hours }

        expect { user.index }.to change(SunspotOffline::Sidekiq::IndexWorker.jobs, :size).by(1)

        expect(Time.at(SunspotOffline::Sidekiq::IndexWorker.jobs.first['at'])).to eq(Time.zone.now + 24.hours)
      end

      it 'queues request for a later execution to a named queue' do
        SunspotOffline.configure { |config| config.default_queue = 'solr' }

        expect { user.index }.to change(SunspotOffline::Sidekiq::IndexWorker.jobs, :size).by(1)

        expect(SunspotOffline::Sidekiq::IndexWorker.jobs.first['queue']).to eq('solr')
      end
    end

    context 'for removing documents' do
      it 'queues remove_by_id request for a later execution' do
        id_list = [user_id, user_id + '1']

        expect { Sunspot.remove_by_id(User, id_list) }.to(
          change(SunspotOffline::Sidekiq::RemovalWorker.jobs, :size).by(1)
        )

        expect(SunspotOffline::Sidekiq::RemovalWorker.jobs.first['args']).to eq([User.name, id_list])
      end

      it 'queues remove_all request for a later execution' do
        expect { Sunspot.remove_all(User) }.to change(SunspotOffline::Sidekiq::RemovalWorker.jobs, :size).by(1)

        expect(SunspotOffline::Sidekiq::RemovalWorker.jobs.first['args']).to eq([User.name, nil])
      end

      it 'queues drop index request for a later execution' do
        expect { Sunspot.remove_all(nil) }.to change(SunspotOffline::Sidekiq::RemovalWorker.jobs, :size).by(1)

        expect(SunspotOffline::Sidekiq::RemovalWorker.jobs.first['args']).to eq([nil, nil])
      end
    end

    context 'for Sidekiq jobs' do
      let(:worker) { DummyWorker.new }

      it 'should not handle errors in filtered jobs' do
        SunspotOffline.configure do |config|
          config.handle_sidekiq_job = ->(job_class) { DummyWorker.name != job_class }
        end

        SunspotOffline::Sidekiq::CurrentJobMiddleware.new.call(worker, {}, 'default') do
          expect { worker.perform }.to raise_error(RuntimeError)
          expect(SunspotOffline::Sidekiq::IndexWorker.jobs).to be_blank
        end
      end

      it 'should handle errors in non filtered jobs' do
        SunspotOffline.configure do |config|
          config.handle_sidekiq_job = ->(job_class) { job_class != 'SomeJob' }
        end

        SunspotOffline::Sidekiq::CurrentJobMiddleware.new.call(worker, {}, 'default') do
          expect { worker.perform }.to change(SunspotOffline::Sidekiq::IndexWorker.jobs, :size).by(1)
        end
      end
    end
  end
end

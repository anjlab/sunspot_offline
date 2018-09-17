require 'sidekiq'

class DummyWorker
  include Sidekiq::Worker

  def perform
    Sunspot.index(User.all)
  end
end

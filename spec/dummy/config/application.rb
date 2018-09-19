require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require "sunspot_offline"

module Dummy
  class Application < Rails::Application
  end
end


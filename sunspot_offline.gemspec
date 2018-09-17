lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sunspot_offline/version'

Gem::Specification.new do |s|
  s.name        = 'sunspot_offline'
  s.version     = SunspotOffline::VERSION
  s.authors     = ['Sergey Glukhov']
  s.email       = ['sergey.glukhov@gmail.com']
  s.summary     = 'Simple failover method into your sunspot_rails + sidekiq setup'
  s.description = 'Simple failover method into your sunspot_rails + sidekiq setup'
  s.homepage    = 'https://github.com/anjlab/sunspot_offline'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_development_dependency 'bundler', '~> 1.16'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.6'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'solr_wrapper'
  s.add_development_dependency 'sqlite3'

  s.add_runtime_dependency 'request_store'
  s.add_runtime_dependency 'sidekiq'
  s.add_runtime_dependency 'sunspot_rails', '~> 2.3'
end

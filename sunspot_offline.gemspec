lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sunspot_offline/version'

Gem::Specification.new do |s|
  s.name        = 'sunspot_offline'
  s.version     = SunspotOffline::VERSION
  s.authors     = ['Sergey Glukhov']
  s.email       = ['sergey.glukhov@gmail.com']
  s.summary     = 'Simple failover method into your sunspot_rails + sidekiq setup'
  s.description = 'Because Solr sometimes fails, it happens. '\
                  'It might be a maintenance work you have to do or just Out-Of-Memory problems. '\
                  'If you are running search-sensitive Rails app, you have to deal with it.'\
                  'This gem was developed to postpone your index tasks automatically into a sidekiq queue '\
                  'if Solr engine becomes unavailable'
  s.homepage    = 'https://github.com/anjlab/sunspot_offline'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_development_dependency 'appraisal', '~> 2.1'
  s.add_development_dependency 'rake', '>= 12.3.3'
  s.add_development_dependency 'rspec', '~> 3.6'
  s.add_development_dependency 'rubocop', '0.59.1'
  s.add_development_dependency 'solr_wrapper', '2.0'
  s.add_development_dependency 'sqlite3', '~> 1.3.6'

  s.add_runtime_dependency 'rails', '>= 5'
  s.add_runtime_dependency 'request_store', '~> 1.4'
  s.add_runtime_dependency 'sidekiq', '>= 4'
  s.add_runtime_dependency 'sunspot_rails', '~> 2.3'
end

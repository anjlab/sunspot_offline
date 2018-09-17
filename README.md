# Sunspot Offline
Simple fail over method into your [sunspot_rails](https://github.com/sunspot/sunspot) + [sidekiq](https://github.com/mperham/sidekiq) setup

## Why?

Because Solr sometimes fails, it happens. It might be a maintenance work you have to do or just Out-Of-Memory problems.
If you are running search-sensitive Rails app, you have to deal with it.
This gem was developed to postpone your index tasks automatically into a sidekiq queue if Solr engine becomes unavailable

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'sunspot_offline'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install sunspot_offline
```

## Configuration

By default gem is configured to use built-in workers which will auto-retry indexing in 1 hour is Solr goes offline.
This all if configurable, preferable via initializer:

```ruby
# config/initializers/sunspot_offline.rb
  
SunspotOffline.configure do |config|
  config.retry_delay = 1.hour
end
```

### Valid configuration options

|Option         | Type| Default value|                      |
|---------------|-----|--------------|----------------------|
| index_job | Class| [bundled worker class](lib/sunspot_offline/sidekiq/index_worker.rb) | Sidekiq worker which will retry **saving new documents** to Solr. Accepts 2 arguments: ActiveRecord class and id (numbers, arrays, and hashes are all valid for this argument) |
| removal_job | Class| [bundled worker class](lib/sunspot_offline/sidekiq/removal_worker.rb) | Sidekiq worker which will retry **removing existing documents** from Solr. Accepts same set of arguments as `index_job`.
| retry_delay | Duration | 1 hour | Delay in which sidekiq will attempt to run `index_job` or `removal_job` |
| default_queue | String | 'default' | Sidekiq's named queue to use |
| on_handled_exception | Proc | `nil` | A proc which will be executed if Solr is detected to be offline |
| handle_sidekiq_job | Proc | `nil` | Since some Solr indexing might be happening inside yours sidekiq jobs they dont need to have a custom fail over, sidekiq is able to retry failures by itself. Using this proc you can configure which jobs could be filtered out:<br>`->(job_name) { !job_name.start_with?('Solr') }` |

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Run tests (`appraisal install && appraisal rake`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

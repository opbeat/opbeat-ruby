# Opbeat

## Installation

Add the following to your `Gemfile`:

```ruby
gem "opbeat", "~> 3.0"
```

The Opbeat gem adhere to [Semantic
Versioning](http://guides.rubygems.org/patterns/#semantic-versioning)
and so you can safely trust all minor and patch versions (e.g. 3.x.x) to
be backwards compatible.

## Usage

### Rails 3 and Rails 4

Add the following to your `config/environments/production.rb`:

```ruby
Rails.application.configure do
  # ...
  config.opbeat.organization_id = 'XXX'
  config.opbeat.app_id = 'XXX'
  config.opbeat.secret_token = 'XXX'
end
```

### Rails 2

No support for Rails 2.

### Rack

Basic RackUp file.

```ruby
require 'opbeat'

config = Opbeat::Configuration.new do |conf|
  conf.organization_id = 'XXX'
  conf.app_id = 'XXX'
  conf.secret_token = 'XXX'
end

Opbeat.start! config

use Opbeat::Middleware 

```

## Background processing

Opbeat automatically catches exceptions in [delayed_job](https://github.com/collectiveidea/delayed_job) or [sidekiq](http://sidekiq.org/).

To enable Opbeat for [resque](https://github.com/resque/resque), add the following (for example in `config/initializers/opbeat_resque.rb`):

```ruby
require "resque/failure/multiple"
require "opbeat/integration/resque"

Resque::Failure::Multiple.classes = [Resque::Failure::Opbeat]
Resque::Failure.backend = Resque::Failure::Multiple
```

## Testing and development

```bash
$ bundle install
$ rspec spec
```

## Resources

* [Bug Tracker](http://github.com/opbeat/opbeat-ruby/issues)
* [Code](http://github.com/opbeat/opbeat-ruby)

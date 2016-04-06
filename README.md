<h1>
  <img src='http://opbeat-brand-assets.s3-website-us-east-1.amazonaws.com/svg/logo/logo.svg' width=400 alt='Opbeat' />
</h1>

[![Build status](https://travis-ci.org/opbeat/opbeat-ruby.svg)](https://travis-ci.org/opbeat/opbeat-ruby)

## Installation

Add the following to your `Gemfile`:

```ruby
gem 'opbeat', '~> 3.0'
```

The Opbeat gem adhere to [Semantic
Versioning](http://guides.rubygems.org/patterns/#semantic-versioning)
and so you can safely trust all minor and patch versions (e.g. 3.x.x) to
be backwards compatible.

## Usage

### Rails 3 and Rails 4

Add the following to your `config/environments/production.rb`:

```ruby
Rails.application.configure do |config|
  # ...
  config.opbeat.organization_id = 'XXX'
  config.opbeat.app_id = 'XXX'
  config.opbeat.secret_token = 'XXX'
end
```

### Rack

```ruby
require 'opbeat'

# set up an Opbeat configuration
config = Opbeat::Configuration.new do |conf|
  conf.organization_id = 'XXX'
  conf.app_id = 'XXX'
  conf.secret_token = 'XXX'
end

# start the Opbeat client
Opbeat.start! config

# install the Opbeat middleware
use Opbeat::Middleware

```

## Configuration

Opbeat works with just the authentication configuration but of course there are other knobs to turn. For a complete list, see [configuration.rb](https://github.com/opbeat/opbeat-ruby/blob/master/lib/opbeat/configuration.rb).

#### Enable in development and other environments

As a default Opbeat only runs in production. You can make it run in other environments by adding them to the `enabled_environments` whitelist.

```ruby
config.opbeat.enabled_environments += %w{development}
```

#### Ignore specific exceptions

```ruby
config.opbeat.excluded_exceptions += %w{
  ActiveRecord::RecordNotFound
  ActionController::RoutingError
}
```

### Sanitizing data

Opbeat can strip certain data points from the reports it sends like passwords or other sensitive information. If you're on Rails the list will automatically include what you have in `config.filter_parameters`.

Add or modify the list using the `filter_parameters` configuration:

```ruby
config.opbeat.filter_parameters += [/regex(p)?/, "string", :symbol]
```

### User information

Opbeat can automatically add user information to errors. By default it looks for at method called `current_user` on the current controller. To change the method use `current_user_method`.

```ruby
config.opbeat.current_user_method = :current_employee
```

### Error context

You may specify extra context for errors ahead of time by using `Opbeat.set_context` eg:

```ruby
class DashboardController < ApplicationController
  before_filter do
    Opbeat.set_context(timezone: current_user.timezone)
  end
end
```

or by specifying it as a block using `Opbeat.context` eg:

```ruby
Opbeat.with_context(user_id: @user.id) do
  UserMailer.welcome_email(@user).deliver_now
end
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

## Manual profiling

It's easy to add performance tracking wherever you want using the `Opbeat` module.

Basically you have to know about two concepts: `Transaction` and `Trace`.

**Transactions** are a bundles of transactions. In a typical webapp every request is wrapped in a transaction. If you're instrumenting worker jobs, a single job run would be a transaction.

**Traces** are spans of time that happen during a transaction. Like a call to the database, a render of a view or a HTTP request. Opbeat will automatically trace the libraries that it knows of and you can manually trace whatever else you'd like to.

The basic api looks like this:

```ruby
Opbeat.transaction "Transaction identifier" do
  data = Opbeat.trace "Preparation" do
    prepare_data
  end
  Opbeat.trace "Description", "kind" do
    perform_expensive_task data
  end
end.done(200)
```

Here, for example is how you could profile a Sidekiq worker job:

```ruby
class MyWorker
  include Sidekiq::Worker

  def perform
    Opbeat.transaction "MyWorker#perform", "worker.sidekiq" do
      User.find_each do |user|
        Opbeat.trace 'run!' do
          user.sync_with_payment_provider!
        end
      end
    end.submit(true)
    # `true` here is the result of the transaction
    # eg 200, 404 and so on for web requests but
    # anything that translates into JSON works

    Opbeat.flush_transactions # send transactions right away
  end
end
```

If you are inside a web request, you are already inside a transaction so you only need to use trace:

```ruby
class UsersController < ApplicationController

  def extend_profiles
    users = User.all

    Opbeat.trace "prepare users" do
      users.each { |user| user.extend_profile! }
    end

    render text: 'ok'
  end

end
```

## Testing and development

```bash
$ bundle install
$ rspec spec
```

## Legacy

Be aware that 3.0 is a almost complete rewrite of the Opbeat ruby client. It is not api compliant with version 2 and below.

## Resources

* [Bug Tracker](http://github.com/opbeat/opbeat-ruby/issues)
* [Code](http://github.com/opbeat/opbeat-ruby)

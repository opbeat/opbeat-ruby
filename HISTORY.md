# 3.0.9

- Fix Rails 5 support

# 3.0.8

- Add support for Rails 5
- Fix support for newer versions of Sequel

# 3.0.7

**Features**

- Add `config.worker_quit_timeout` (default is 5 secs) ([@jensnockert](https://github.com/jensnockert))
- Add `Opbeat.with_context` for block-specific contexts ([@jensnockert](https://github.com/jensnockert))

# 3.0.6

**Fixes**

- Actually add `Opbeat.set_context`

# 3.0.4

**Features**

- Added `Opbeat.set_context`.

**Fixes**

- Make the SQL descriptions fall back to just `SQL` ([@jensnockert](https://github.com/jensnockert))

# 3.0.3

**Features**

- Support optional key-value extra info on error messages ([@jensnockert](https://github.com/jensnockert))

**Fixes**

- Stacktraces have bin flipped so the most relevant line is on top ([@jensnockert](https://github.com/jensnockert))

# 3.0.2

**Fixes**

- Ensure worker is running when reporting errors ([@jensnockert](https://github.com/jensnockert))
- Increase timeout when closing worker thread and report failure - ([@jensnockert](https://github.com/jensnockert))

# 3.0.1

**Fixes**

- Sidekiq error handler takes two arguments (#10)

# v3.0.0

3.0.0 marks a fresh start. Follow this file onwards for update information.

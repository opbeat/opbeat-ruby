require 'capistrano'
require 'capistrano/version'

if Capistrano::VERSION.to_i <= 2
  require 'opbeat/integration/capistrano2'
else
  require 'opbeat/integration/capistrano3'
end

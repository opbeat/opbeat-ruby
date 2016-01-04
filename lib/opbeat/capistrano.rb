require 'capistrano'
require 'capistrano/version'

if Capistrano.constants.include? :VERSION
  require 'opbeat/integration/capistrano2'
else
  require 'opbeat/integration/capistrano3'
end

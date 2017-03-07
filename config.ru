require __dir__ + '/lib/navplanner'

if ENV['SENTRY_DSN']
  require 'raven'
  Raven.configure do |config|
    config.dsn = ENV.fetch('SENTRY_DSN')
  end
  use Raven::Rack
end

run NavplannerWeb
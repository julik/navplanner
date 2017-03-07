require __dir__ + '/lib/navplanner'

require 'raven'
if ENV['SENTRY_DSN']
  Raven.configure do |config|
    config.dsn = ENV.fetch('SENTRY_DSN')
  end
  use Raven::Rack
end

run NavplannerWeb
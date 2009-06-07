require 'rubygems'
require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'imp'
require 'imp/test'

Spec::Runner.configure do |config|
  config.include(Imp::Test::RouteHelper)
end

# TODO: Remove fixtures.

class Find < Imp::Command
end

class FindAll < Imp::Command
end

Imp::Router.reset!

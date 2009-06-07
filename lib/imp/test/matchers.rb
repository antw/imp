module Imp::Test
  module Rspec; end
end

require File.join(File.dirname(__FILE__), 'matchers', '') + 'route_matchers'

module Imp::Test::RouteHelper
  include Imp::Test::Rspec::RouteMatchers
end

#--
# Another tip of the hat to the Merb devs; this is all rather similar to
# Merb::Test::Rspec::RouteMatchers...
#++

module Imp::Test::Rspec::RouteMatchers

  class RouteToMatcher

    ##
    # ==== Parameters
    # klass<Class>::  The expected command class.
    # action<~to_s>:: The expected action name.
    #
    def initialize(command, action)
      @expected_command = Extlib::Inflection.classify(command.to_s)
      @expected_action  = action.to_s
    end

    ##
    # ==== Parameters
    # target<Hash>::
    #   The generated route to be matched against the expected values.
    #
    # ==== Returns
    # Boolean:: True if the command and action match.
    #
    def matches?(target)
      @target = target

      not @target.nil? and
          Extlib::Inflection.classify(@target.command.to_s) ==
              @expected_command and
          @target.action.to_s  == @expected_action
    end

    # Failure messages.

    def failure_message_for_should
      was = if @target.nil?
        'nil (no matching route found)'
      else
        '%s#%s' % [@target.command, @target.action]
      end

      'expected route to %s#%s, but was %s' % [
        @expected_command, @expected_action, was
      ]
    end

    def failure_message_for_should_not
      'expected not to be a route to %s#%s, but it was' % [
        @expected_command, @expected_action
      ]
    end

  end

  ##
  # Passes when the given route matches the expected command class and action.
  #
  # ==== Parameters
  # klass<Class>::  The expected command class.
  # action<~to_s>:: The expected action name.
  #
  # ==== Example
  #
  #   # Passes if the given route was successfully matched to the 'Find'
  #   # command and the 'all' action.
  #   Imp::Router.match('find all').should be_route(Find, :all)  #
  #
  def route_to(command, action)
    RouteToMatcher.new(command, action)
  end
end

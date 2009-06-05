module Imp
  ##
  # The Router matches command and action names to the correct Command class.
  #
  class Router
    @route_map = {}

    MatchedRoute = Struct.new(:command, :action, :args)

    class << self

      ##
      # Takes an array of arguments and attempts to find a route which
      # matches.
      #
      # If a matching route can be found, an array will be returned
      # containing:
      #
      #   - a hash with +:command+ and +:action+ keys
      #   - an array of arguments with the route segments removes.
      #
      # If there was no matching route found, nil will be returned.
      #
      # ==== Parameters
      # args<Array>:: An array of arguments to be used to match a route.
      #
      # ==== Returns
      # Imp::Router::MatchedRoute:: If a matching route was found.
      # nil:: If no match was found.
      #
      # :api: private
      #
      def match(args)
        # Fetch the leading non-option arguments.
        segments = []
        until Imp::Options::OptionParser.is_switch?(args.first) || args.empty?
          segments << args.shift
        end

        match = until segments.empty?
          if @route_map.has_key?(segments.join(' '))
            break @route_map[segments.join(' ')]
          else
            # Pop off the right-most segment and add it back to the args, then
            # try to match again.
            args.unshift(segments.pop) && false
          end
        end

        if match
          action = if match[:action]
            match[:action]
          elsif legal_action_string?(args.first)
            # There were left-over segments, use the first one as the action
            # name.
            Extlib::Inflection.underscore(args.shift).to_sym
          else
            # There were no left-over segments (or what would be used as the
            # action is unsuitable), so we use the default.
            :default
          end

          MatchedRoute.new(match[:command], action, args)
        end
      end

      ##
      # Registers a new command route with the router.
      #
      # ==== Parameters
      # route<String>::         The route path.
      # command<Imp::Command>:: The command for the route.
      # action<String>::        An (optional) action.
      #
      # ==== Examples
      # Standard usage
      #
      #   Imp::Router.register('find', Find)
      #   # Maps '$ myapp find ...' to the Find command.
      #
      # With an action
      #
      #   Imp::Router.register('find everything', Find, :all)
      #   # => Maps '$ myapp find everything' to the 'all' action on the Find
      #        command.
      #
      # :api: private
      #
      def register(route, command, action = nil)
        @route_map[route] = { :command => command, :action => action }
        nil
      end

      ##
      # Removes a route identified by +route+ from the router.
      #
      # ==== Parameters
      # route<String>:: The name of the route to be removed.
      #
      # :api: private
      #
      def remove(route)
        @route_map.delete(route)
        nil
      end

      ##
      # Returns a hash of registered routes with the route as the key, and
      # command/action as the values.
      #
      # Returns all of the registered routes.
      #
      # ==== Returns
      # Hash::
      #   A hash containing route names as the keys, and a hash containing
      #   the command and action for the route.
      #
      # :api: public
      #
      def routes
        @route_map.dup
      end

      ##
      # Removes all registered routes.
      #
      # :api: private
      #
      def reset!
        @route_map = {}
      end

      #######
      private
      #######

      def legal_action_string?(candidate)
        not candidate.nil? and
        not Imp::Options::OptionParser.is_switch?(candidate) and
        not candidate =~ /[^a-z\-]/
      end

    end # class << self
  end # Router
end # Imp

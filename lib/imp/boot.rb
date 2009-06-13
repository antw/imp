module Imp
  class Boot

    class << self

      ##
      # Loads an Imp application.
      #
      # * Verifies that the path exists and appears to be an Imp directory.
      # * Loads the configuration (any values set in Imp::Config prior to this
      #   point are removed).
      # * Loads the Commands and registers them with the router.
      #
      # Use Imp::load_application rather than Imp::Boot.boot.
      #
      # ==== Returns
      # true:: Returns true if loading completed without any errors.
      #
      # ==== Raises
      # ApplicationLoadError::
      #   Raises ApplicationLoadError if some part of the application load
      #   process did not work.
      #
      # :api: private
      #
      def boot(path)
        # Reset configuration.
        Imp::Config.setup
        Imp::Router.reset!

        load_config(path)
        load_commands
        register_commands_with_router

        true
      end

      #######
      private
      #######

      ##
      # Normalises the given path by figuring out if it is a path to the root
      # of an Imp application, or a path to a config file. Then loads the
      # config file.
      #
      def load_config(path)
        # Set the impfile and initial root path settings...
        if File.file?(path.chomp('.rb') + '.rb')
          # Received a path to a configuration file.
          Imp::Config[:root_path] = File.expand_path(File.dirname(path))
          Imp::Config[:impfile] = File.expand_path(path.chomp('.rb') + '.rb')
        else
          # Received a directory in which the app is located, expect an imp.rb
          # configuration file to be present.
          Imp::Config[:root_path] = File.expand_path(path)
          Imp::Config[:impfile] = File.expand_path(File.join(path, 'imp.rb'))
        end

        unless File.file?(Imp::Config[:impfile])
          raise ApplicationLoadError, "Couldn't load app at #{path}"
        end

        # TODO: This is decidedly ugly.
        Imp::Command._subclasses = Set.new

        load Imp::Config[:impfile]
      end

      ##
      # Loads all of the files in the application.
      #
      def load_commands
        glob = File.join(Imp.root, '**', '*.rb')
        Dir[glob].sort.each { |f| load f }
      end

      ##
      # Registers each of the command subclasses with the router.
      #
      def register_commands_with_router
        Imp::Command._subclasses.each do |klass|
          Imp::Router.register(klass.command_name, klass)
        end
      end

    end # class << self

  end
end

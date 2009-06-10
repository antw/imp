module Imp
  class Config

    class << self

      ##
      # Sets a configuration entry.
      #
      # ==== Parameters
      # key<Object>::   The name for the configuration entry.
      # value<Object>:: A value to assign to the key.
      #
      # :api: public
      #
      def []=(key, value)
        config[key] = value
      end

      ##
      # Returns the value of a configuration entry. Returns nil if the key
      # is not present.
      #
      # ==== Parameters
      # key<Object>:: The key of the config entry.
      #
      # :api: public
      #
      def [](key)
        config[key]
      end

      ##
      # Removes and returns an entry identified by +key+.
      #
      # ==== Parameters
      # key<Object>: The key to remove.
      #
      # :api: public
      #
      def delete(key)
        config.delete(key)
      end

      ##
      # Retrieves an entry identified by +key+. If it is not set, +default+ is
      # returned instead.
      #
      # ==== Parameters
      # key<Object>::     The key whose value you want to fetch.
      # default<Object>:: The value to return if the key is not set.
      #
      # :api: public
      #
      def fetch(key, default)
        config.fetch(key, default)
      end

      ##
      # Returns whether the given +key+ is found in the configuration.
      #
      # ==== Paramters
      # key<Object>:: The key to look for.
      #
      # ==== Returns
      # Boolean
      #
      # :api: public
      #
      def has_key?(key)
        config.has_key?(key)
      end

      ##
      # Sets up the config.
      #
      # ==== Parameters
      # initial_config<Hash>:: Initial values to be added to the config.
      #
      # :api: private
      #
      def setup(initial_config = {})
        @config = defaults.merge(initial_config)
      end

      #######
      private
      #######

      ##
      # Returns sensible default values which should suit most Imp applications.
      #
      # ==== Returns
      # Hash:: A frozen hash containing default values.
      #
      # :api: private
      #
      def defaults
        @defaults ||= {
          :in  => STDIN,
          :out => STDOUT
        }
      end

      ##
      # Returns the internal config store (a hash).
      #
      # ==== Return
      # Hash:: The config store.
      #
      # :api: private
      #
      def config
        @config || setup
      end

    end # class << self

  end # Config
end # Imp

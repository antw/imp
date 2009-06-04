module Imp
  ##
  # Contains classes related to command-ling option parsing.
  #
  # The OptionParser class owes a great deal to Thor's Options class (licensed
  # under the MIT License). My thanks to Yehuda Katz.
  #
  module Options
    ##
    # A Hash extension supporting indifferent access.
    #
    # @api private
    #
    class Mash < Hash
      attr_accessor :leading_non_opts, :trailing_non_opts

      def initialize(hash = nil)
        super()
        update(hash) unless hash.nil?
        @leading_non_opts, @trailing_non_opts = [], []
      end

      def [](key)
        super convert_key(key)
      end

      def []=(key, value)
        super(convert_key(key), value)
      end

      def update(other)
        other.each_pair { |k, v| self[k] = v }
        self
      end

      #######
      private
      #######

      def convert_key(key)
        Symbol === key ? key.to_s : key
      end
    end # Mash

    ##
    # Represents a single option, and all the settings which go along with it.
    #
    class Option
      DSL_METHODS = [
        :long, :short, :description, :default, :cast, :required
      ].freeze

      attr_reader   :name
      attr_accessor *DSL_METHODS

      ##
      # Defines a new Option. Requires, at a bare minimum, that a name be
      # provided. You may further configure the Option by providing a block.
      #
      # @api private
      #
      def self.define(name, &blk)
        Generator.new(name).gen(&blk)
      end

      def initialize(name)
        @name = name
      end

      def required?
        @required
      end

      def numeric?
        (! @cast.nil?) && Numeric >= @cast
      end

      def boolean?
        @cast == TrueClass || @cast == FalseClass
      end

      def typecast(val)
        if numeric?
          if not val.kind_of?(String)
            raise Imp::OptionError, "Switch requires a value: #{@long}"
          elsif val =~ /[^0-9.]/
            raise Imp::OptionError, "Switch requires numeric argument: #{@long}"
          end

          val.index('.') ? val.to_f : val.to_i
        else
          val
        end
      end

      ##
      # The Generator is responsible for creating an Option instance using a
      # given confiuration block. We use a Generator here so as to provide the
      # +long+, +short+, etc, methods, without muddying up the Option class.
      #
      # Internally the Generator keeps track of which attributes have been
      # explicitly set, and finishes off by auto-setting the +short+ and
      # +cast+ values if the user has not set them.
      #
      # @api private
      #
      class Generator
        ##
        # Creates a new Generator instance.
        #
        # @param [Symbol] name The name of the option.
        #
        def initialize(name)
          @option = Option.new(name)
          @set = Set.new
        end

        Imp::Options::Option::DSL_METHODS.each do |meth|
          class_eval <<-RUBY, __FILE__, __LINE__
            def #{meth}(val)          # def long(val)
              @set << :#{meth}        #   @set << :long
              @option.#{meth} = val   #   @option.long = val
            end                       # end
          RUBY
        end

        ##
        # Sets up the Option instance according to the given configuration
        # block.
        #
        def gen(&blk)
          instance_eval(&blk) if blk

          # Auto-set a long value?
          if @option.long.nil?
            long '--' + @option.name.to_s.
              gsub(/[^a-z\-]/, '-').gsub(/-{2,}/, '-')
          end

          # Auto-set a short value?
          unless @set.include?(:short)
            short @option.long[1..2]
          end

          # Auto-set a cast value?
          if not @set.include?(:cast) and not @option.default.nil?
            cast @option.default.class
          end

          @option
        end

      end # Option::Generator
    end

    ##
    # Permits the definition of options for a Command through a nice(ish) DSL
    # and then parses the given arguments into something meaningful.
    #
    # @api private
    #
    class OptionParser

      NUMERIC             = /(\d*\.\d+|\d+)/
      LONG_SWITCH         = /^(--\w+[-\w+]*)$/              # --switch
      LONG_EQ_SWITCH      = /^(--\w+[-\w+]*|-[a-z])=(.*)$/i # --switch=<value>
      SHORT_SWITCH        = /^(-[a-z])$/i                   # -a
      SHORT_JOINED_SWITCH = /^-([a-z]{2,})$/i               # -abc
      SHORT_EQ_SWITCH     = /^(-[a-z])#{NUMERIC}$/i         # -n12

      ##
      # Creates a new OptionParser instance. Expects to be given an array of
      # defined Options.
      #
      def initialize(options = [])
        @options, @shorts = {}, {}

        options.each do |option|
          @options[option.long] = option
          @shorts[option.short] = option unless option.short.nil?
        end
      end

      ##
      # Parses the given +args+.
      #
      # @param [Array] args
      #   The arguments to be parsed (typically provided as an array).
      #
      # @return [Imp::Options::Mash]
      #
      # @api private
      #
      def parse(args)
        @args   = args
        results = Mash.new(defaults)

        # Remove leading values which are not a switch (-f or --fxxx).
        results.leading_non_opts << shift until current_is_switch? || @args.empty?
        results.leading_non_opts.freeze

        while current_is_switch?
          case switch = shift
          when SHORT_JOINED_SWITCH
            unshift $1.split('').map { |f| "-#{f}" }
            next
          when LONG_EQ_SWITCH, SHORT_EQ_SWITCH
            unshift $2
            option = option_for($1)
          when LONG_SWITCH, SHORT_SWITCH
            option = option_for($1)
          end

          # If no option could be found matching the switch, the user has
          # specified an invalid switch. Raise the error.
          raise Imp::InvalidSwitch,
            "An invalid option was specified: #{switch}" if option.nil?

          # Get the option value, if applicable.
          if option.required?
            if peek.nil? || option_for(peek)
              raise Imp::OptionError, "Switch requires a value: #{switch}"
            end

            results[option.name] = shift
          elsif option.boolean?
            results[option.name] = switch !~ /^--no-/
          else
            results[option.name] = option.typecast(
              peek.nil? || (!! option_for(peek)) || shift
            )
          end
        end

        results.trailing_non_opts = @args.freeze

        # Ensure that the required options are set.
        ensure_required_options_are_set!(results)

        results.freeze
      end

      #######
      private
      #######

      ##
      # Returns an hash of option keys and their default values. Options
      # without a default are ignored.
      #
      def defaults
        @options.inject({}) do |m, (k,v)|
          m[v.name] = v.default unless v.default.nil? ; m
        end
      end

      ##
      # Pops the first argument off the arguments array.
      #
      def shift
        @args.shift
      end

      ##
      # Returns the first argument in the arguments array, without removing
      # it.
      #
      def peek
        @args.first
      end

      ##
      # Retrieves an Option by it's long or short switch.
      #
      def option_for(switch)
        if @options.has_key?(switch)
          @options[switch]
        elsif @shorts.has_key?(switch)
          @shorts[switch]
        elsif switch =~ /^--no-(\S+)$/
          found = @options["--#{$1}"]
          (found.boolean? && "--#{$1}" == found.long) ? found : nil
        end
      end

      ##
      # Returns if the current argument looks like it should be a switch.
      #
      def current_is_switch?
        peek =~ /^-/
      end

      ##
      # Adds an item (or items) to the front of the args array.
      #
      def unshift(arg)
        Array === arg ? @args = arg + @args : @args.unshift(arg)
      end

      ##
      # Ensures that required options are set in the given Mash.
      #
      def ensure_required_options_are_set!(results)
        missing = @options.inject([]) do |m, (_, opt)|
          m << opt.long if opt.required? && results[opt.name].nil? ; m
        end

        unless missing.empty?
          raise Imp::MissingRequiredOption, "The following options are " \
            "required, but were not given: #{missing.join(', ')}"
        end
      end

    end
  end
end

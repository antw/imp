module Imp
  ##
  # Imp::Command forms the base of your Imp application.
  #
  # Having generated your Imp application, you should find a class called
  # +Application+ inside your application.rb file. Your own commands should
  # inherit from this Application class. You can add common logic, filters or
  # helpers to the Application class without having to resort to
  # monkey-patching Imp::Command.
  #
  #   # in application.rb...
  #   class Application < Imp::Command
  #   end
  #
  #   # in find.rb...
  #   class Find < Application
  #     def default
  #       say "This is the default find action; you called 'myapp find'."
  #     end
  #
  #     def audio
  #       say "This is the audio action; you called 'myapp find audio'."
  #     end
  #   end
  #
  # == Command names
  #
  # Imp maps commands sent on the command line to Command instances in your
  # application automatically.
  #
  #   $ myapp find     # Maps to a command called Find.
  #   $ myapp find all # Maps to a command called FindAll.
  #
  # To change the default name for your command, use the +command+ helper...
  #
  #   class FindAll < Application
  #     command 'findall'
  #   end
  #
  # The above example defines a command called 'findall' instead of 'find all'
  # which would be called like this:
  #
  #   $ myapp findall
  #
  # == Arguments
  #
  # Arguments are passed on the command line after the name of your program
  # and the command name. To take a common real-world example from Git:
  #
  #   $ git rebase --interactive
  #
  # If Git were to use Imp, 'git' is the name of your application, with
  # 'rebase' being the command, and '--interactive' being an argument. Imp
  # supports both long form and short form arguments...
  #
  #   $ git rebase -i
  #
  # Imp mandates that all arguments have a long form, however a short form is
  # not required.
  #
  # Defining an argument is fairly simple:
  #
  #   arg :force do
  #     long '--force'
  #     short '-f'
  #   end
  #
  # This defines an argument with a long form of '--long' and short form of
  # '-f'. In the event that don't explictly set a long or short form, Imp is
  # smart enough to set some sensible defaults; the name of the argument will
  # be used as the long form, with the first character being used to create
  # the short form. Therefore, the above example can be simplified to:
  #
  #   arg :force
  #
  # You can further customise your argument by setting a 'default', 'cast',
  # 'description', or if the argument is mandatory.
  #
  #   arg :number do
  #     description 'Sets the number of results to be returned.'
  #     required    true
  #     default     10
  #     cast        Numeric
  #   end
  #
  # This sets an argument called 'number' (with long form --number and short
  # form -n), which the user must specify, a default value of 10, and and the
  # value will be automatically cast to Numeric (Numeric is the only supported
  # cast at the time of writing).
  #
  # Parsed arguments will be made available via the +arguments+ helper in your
  # command...
  #
  #   $ myapp mycommand --number 10 -f
  #
  #   def mycommand
  #     arguments[:number] # => 10
  #     arguments[:force]  # => true
  #   end
  #
  # Extra arguments passed on the command line which are not recognised as a
  # switch (that is, arguments which are a mapping to a command, and don't
  # begin with a dash) can also be accessed via the +arguments+ help.
  #
  #   $ myapp mycommand leading argument --number 10 -f file.rb another
  #
  #   def mycommand
  #     arguments[:number]          # => 10
  #     arguments[:force]           # => true
  #     arguments.leading_non_opts  # => ['leading', 'argument']
  #     arguments.trailing_non_opts # => ['file.rb', 'another']
  #   end
  #
  class Command

    class_inheritable_accessor :_arguments
    self._arguments = []

    cattr_accessor :_subclasses
    self._subclasses = Set.new

    ##
    # Sets a custom name for the command.
    #
    # ==== Paramters
    # name<String>:: The new name for the command
    #
    # :api: public
    #
    def self.command(name)
      # Set the new command name...
      @_command_name = name
    end

    ##
    # Returns the name of the command as a string.
    #
    # ==== Returns
    # String:: Returns the name of the command.
    #
    # :api: public
    #
    def self.command_name
      @_command_name
    end

    ##
    # Adds a new argument to the command. See the Arguments section for
    # Imp::Command for more information.
    #
    # ==== Parameters
    # name<Symbol>:: A name for the argument.
    #
    # :api: public
    #
    def self.arg(name, &configuration)
      _arguments << Imp::Options::Option.define(name, &configuration)
    end

    ##
    # Creates a new Command instance.
    #
    # ==== Parameters
    # arguments<Array>:: An array of arguments to be parsed.
    #
    # :api: plugin
    #
    def initialize(arguments)
      @_unparsed_arguments = arguments
    end

    ##
    # Parses arguments and dispatches the given +action+.
    #
    # ==== Parameters
    # action<Symbol>:: The action to dispatch.
    #
    # :api: plugin
    #
    def _dispatch(action)
      arg_parser  = Imp::Options::OptionParser.new(self.class._arguments)
      @_arguments = arg_parser.parse(@_unparsed_arguments)

      if respond_to?(action)
        send(action)
      else
        raise Imp::ActionNotFound,
          "Action '#{action}' was not found in #{self.class}"
      end
    end

    ##
    # Returns the parsed arguments.
    #
    # ==== Returns
    # Imp::Options::Mash
    # 
    # :api: public
    #
    def arguments
      @_arguments
    end

    #######
    # private
    #######

    ##
    # Performs setup of new Command instances.
    #
    # :api: private
    #
    def self.inherited(klass)
      # Add to subclasses list (used to register command with the router).
      self._subclasses << klass

      # Set the default command name for the new Command.
      klass.command Extlib::Inflection.underscore(klass.to_s.split('::').last).gsub('_', ' ')
    end

  end # Command
end # Imp

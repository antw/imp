imp = File.join(File.dirname(__FILE__), 'imp', '')

# Core Lib.
require 'set'

# Gems.
gem 'extlib'
require File.join('extlib', 'class')
require File.join('extlib', 'inflection')
require File.join('extlib', 'nil')
require File.join('extlib', 'object')
require File.join('extlib', 'string')

# Load Imp.
require imp + 'boot'
require imp + 'command'
require imp + 'config'
require imp + 'options'
require imp + 'router'

module Imp

  VERSION = File.read('VERSION').strip

  # Gneric Imp error class.
  class ImpError < StandardError; end

  # Raised when an application can't be loaded.
  class ApplicationLoadError < ImpError; end

  # Raised when an error occurs during option parsing.
  class OptionError < ImpError; end

  # Raised when a user adds a switch on the CLI which hasn't been defined.
  class InvalidSwitch < OptionError; end

  # Raised when a required option was not present.
  class MissingRequiredOption < OptionError; end

  # Raised when an error happens in the router.
  class RouterError < ImpError; end

  # Raised when attempting to dispatch to an action which does not exist.
  class ActionNotFound < ImpError; end

  ##
  # Loads an application at the given path. Expect to be given either a path
  # to directory containing containing an imp.rb file, and your command files.
  #
  # ==== Parameters
  # path<String>:: A path to an Imp application.
  #
  # ==== Alternatives
  # You may provide a path to an imp.rb file (of any name) if it is found
  # separately from the command files.
  #
  # ==== Examples
  # Loading an application at a given path:
  #
  #   Imp.load_application('/my/app')
  #     # Loads an application in the directory /my/app, and expects
  #     # /my/app/imp.rb to exist.
  #
  #   Imp.load_application('/my/app/my_config_file.rb')
  #     # Loads a configuration file located at /my/app/my_config_file.rb.
  #     # Assumes that the application can be found in /my/app unless you
  #     # explicitly set a :root_path setting.
  #
  # ==== Returns
  # true::  If the application loaded without errors.
  #
  # ==== Raises
  # ApplicationLoadError::
  #   Raises ApplicationLoadError if some part of the application load process
  #   did not complete successfully.
  #
  # :api: public
  #
  def self.load_application(path)
    Imp::Boot.boot(path)
  end

  ##
  # ==== Returns
  # String:: The path to the route of the currently loaded Imp application.
  # nil:: If no application has been loaded.
  #
  # :api: public
  #
  def self.root
    Imp::Config[:root_path]
  end

end

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
require imp + 'application'
require imp + 'command'
require imp + 'config'
require imp + 'options'
require imp + 'router'

module Imp

  VERSION = File.read('VERSION').strip

  # Gneric Imp error class.
  class ImpError < StandardError; end

  # Raised when an error occurs during option parsing.
  class OptionError < ImpError; end

  # Raised when a user adds a switch on the CLI which hasn't been defined.
  class InvalidSwitch < OptionError; end

  # Raised when a required option was not present.
  class MissingRequiredOption < OptionError; end

  # Raised when an error happens in the router.
  class RouterError < ImpError; end

end

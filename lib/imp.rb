imp = File.join(File.dirname(__FILE__), 'imp', '')

require 'set'

require imp + 'application'
require imp + 'options'

module Imp

  VERSION = File.read('VERSION').strip

  # Gneric Imp error class.
  class ImpError < StandardError; end

  # Raised when an error occurs during option parsing.
  class OptionError < ImpError; end

  # Raised when a user adds a switch on the CLI which hasn't been defined.
  class InvalidSwitch < OptionError; end

  # Raised when a required option was not present.
  class Imp::MissingRequiredOption < OptionError; end

end

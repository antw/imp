imp = File.join(File.dirname(__FILE__), 'imp', '')

require imp + 'application'

module Imp

  VERSION = File.read('VERSION').strip

  # Gneric Imp error class.
  class ImpError < StandardError; end

end
